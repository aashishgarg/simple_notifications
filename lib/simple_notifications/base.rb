module SimpleNotifications
  module Base
    mattr_accessor :notified_flag, :entity_class, :sender, :receivers

    #Getter to check if model is enabled with notifications
    def notified?
      !!@@notified_flag
    end

    # Add this method to any model and it starts the notification functionality on the Model.
    # Expects two parameters :sender and :receiver.
    def notify(options = {})
      @@entity_class = self
      @@sender = options[:sender]
      @@receivers = options[:receivers]

      open_sender_class
      open_receiver_class
      open_notified_class

      @@notified_flag = true
    end

    # Opening the class which is defined as sender.
    def open_sender_class
      # Define association for sender model
      sender_class(@@sender).class_eval do
        has_many :sent_notifications, class_name: 'SimpleNotifications::Record', as: :sender
      end
    end

    # Opening the classes which are defined as receivers.
    def open_receiver_class
      # Define association for receiver model
      [receivers_class(@@receivers)].flatten.each do |base|
        base.class_eval do
          has_many :deliveries, class_name: 'SimpleNotifications::Delivery', as: :receiver
          has_many :received_notifications, through: :deliveries, source: :simple_notification
        end
      end
    end

    # Opening the class on which the notify functionality is applied.
    def open_notified_class
      class_eval do
        attr_accessor :message, :notify
        # Define association for the notified model
        has_many :notifications, class_name: 'SimpleNotifications::Record', as: :entity
        has_many :notifiers, through: :notifications, source: :sender, source_type: sender_class(@@sender).to_s

        # Opening the Notification class.
        SimpleNotifications::Record.class_eval do
          [@@entity_class.receivers_class(@@receivers)].flatten.each do |receiver_class|
            has_many "#{receiver_class.name.downcase}_receivers".to_sym,
                     through: :deliveries,
                     source: :receiver,
                     source_type: receiver_class.name
          end
        end

        [receivers_class(@@receivers)].flatten.each do |receiver_class|
          has_many "#{receiver_class.name.downcase}_notificants".to_sym,
                   through: :notifications,
                   source: "#{receiver_class.name.downcase}_receivers".to_sym
        end

        has_many :read_deliveries, through: :notifications, source: :read_deliveries
        has_many :unread_deliveries, through: :notifications, source: :unread_deliveries
        # has_many :notificants, through: :notifications, source: :receivers
        # has_many :read_notificants, through: :read_deliveries, source: :receiver, source_type: 'User'
        # has_many :unread_notificants, through: :unread_deliveries, source: :receiver, source_type: 'User'

        # Callbacks
        after_create_commit :create_notification, if: proc {@notify.nil? || !!@notify}
        after_update_commit :update_notification, if: proc {@notify.nil? || !!@notify}

        # Check if notifications has already been delivered.
        def notified?
          !notifications.blank?
        end

        # Deliver notifications at any time
        def notify(options = {})
          raise 'SimpleNotification::SenderReceiverError' unless options[:sender] && options[:receivers]
          @message = options[:message] if options[:message]
          notification = notifications.build(entity: self, sender: options[:sender],
                                             message: default_message(self, options[:sender], 'created'))
          options[:receivers].each {|receiver| notification.deliveries.build(receiver: receiver)}
          notification.save
        end

        def notificants
          #TODO : Need to eager load
          SimpleNotifications::Record.where(entity: self).collect {|notification| notification.deliveries.collect(&:receiver)}.flatten
        end

        def read_marked_notificants
          #TODO : Need to eager load
          SimpleNotifications::Record.where(entity: self).collect {|notification| notification.deliveries.where(is_read: true).collect(&:receiver)}.flatten
        end

        def unread_marked_notificants
          #TODO : Need to eager load
          SimpleNotifications::Record.where(entity: self).collect {|notification| notification.deliveries.where(is_read: false).collect(&:receiver)}.flatten
        end

        # Mark notifications in read mode.
        # If notificants are provided then only those respective notifications will be marked read.
        # Else all will be marked as read.
        def mark_read(notificants = nil)
          (notificants ? unread_deliveries.where(receiver: notificants) : unread_deliveries).update_all(is_read: true)
        end

        # Mark notifications in unread mode.
        # If notificants are provided then only those respective notifications will be marked unread.
        # Else all will be marked as unread.
        def mark_unread(notificants = nil)
          (notificants ? read_deliveries.where(receiver: notificants) : read_deliveries).update_all(is_read: false)
        end

        private

        def get_obj(sender_or_receivers)
          sender_or_receivers.kind_of?(Symbol) ? send(sender_or_receivers) : sender_or_receivers
        end

        def default_message(entity, sender, action)
          @message || "#{entity.class.name} #{entity.name} #{action}."
        end

        def create_notification
          notify({sender: get_obj(@@sender), receivers: get_obj(@@receivers), message: default_message(self, get_obj(@@sender), 'created')})
        end

        def update_notification
          notify({sender: get_obj(@@sender), receivers: get_obj(@@receivers), message: default_message(self, get_obj(@@sender), 'updated')})
        end
      end
    end

    # Provides the class of Sender
    def sender_class(sender)
      if sender.kind_of? Symbol
        reflections[sender.to_s].klass
      elsif sender.kind_of? ActiveRecord::Base
        sender.class
      else
        raise 'SimpleNotifications::SenderTypeError'
      end
    end

    # Provides the classes of Receivers
    def receivers_class(receivers)
      if receivers.kind_of? Symbol
        reflections[receivers.to_s].klass
      else
        if receivers.kind_of? ActiveRecord::Base
          receivers.class
        elsif receivers.kind_of? ActiveRecord::Relation
          receivers.klass
        elsif receivers.kind_of? Array
          receivers.flatten.collect {|receiver| receivers_class(receiver)}
        else
          raise 'SimpleNotifications::ReceiverTypeError'
        end
      end
    end
  end
end
