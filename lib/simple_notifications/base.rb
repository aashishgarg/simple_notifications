module SimpleNotifications
  module Base
    mattr_accessor :options, :notified_flag

    #Example
    #notify(sender: :author, receivers: :followers)
    #notify sender: :product_class,
    #       receivers: :variants,
    #       action: [:follow, :update, :create, :destroy]
    def notify(options = {})
      @@options = options
      @@options[:entity_class] = self
      @@options[:callbacks] = []
      [:create, :update, :destroy].each {|_method| @@options[:callbacks] << @@options[:actions].delete(_method)}
      @@options[:callbacks].compact!
      open_sender_class
      open_receiver_class
      open_notified_class
      @@notified_flag = true
    end

    #Getter to check if model is enabled with notifications
    def notified?
      !!@@notified_flag
    end

    # Opening the class which is defined as sender.
    def open_sender_class
      # Define association for sender model
      sender_class(@@options[:sender]).class_eval do
        has_many :sent_notifications, class_name: 'SimpleNotifications::Record', as: :sender
      end
    end

    # Opening the classes which are defined as receivers.
    def open_receiver_class
      # Define association for receiver model
      [receivers_class(@@options[:receivers])].flatten.each do |base|
        base.class_eval do
          has_many :deliveries, class_name: 'SimpleNotifications::Delivery', as: :receiver
          has_many :received_notifications, through: :deliveries, source: :simple_notification
        end
      end
    end

    # Opening the class on which the notify functionality is applied.
    def open_notified_class
      class_eval do
        prepend NotificationActions
        attr_accessor :message, :notify_flag

        # Define association for the notified model
        has_many :notifications, class_name: 'SimpleNotifications::Record', as: :entity
        has_many :notifiers, through: :notifications, source: :sender, source_type: sender_class(@@options[:sender]).to_s
        has_many :read_deliveries, through: :notifications, source: :read_deliveries
        has_many :unread_deliveries, through: :notifications, source: :unread_deliveries

        # Callbacks
        after_create_commit :create_notification, if: proc {@@options[:callbacks].include?(:create)}
        after_update_commit :update_notification, if: proc {@@options[:callbacks].include?(:update)}
        after_destroy_commit :destroy_notification, if: proc {@@options[:callbacks].include?(:destroy)}

        NotificationActions.module_eval do
          @@options[:actions].each do |action|
            define_method(action) do
              run_callbacks action do
                super()
              end
            end

            define_method("before_#{action}".to_sym) do
            end

            define_method("after_#{action}".to_sym) do
              self.notify(sender: @@options[:sender], receivers: @@options[:receivers], message: default_message(self, @@options[:sender], action.to_s))
            end
          end
        end

        @@options[:actions].each do |action|
          define_model_callbacks action
          send("before_#{action}", "before_#{action}".to_sym)
          send("after_#{action}", "after_#{action}".to_sym)
        end

        #Example
        #post.notify(sender: :author, receivers: :followers, message: 'My Custom logic message')
        #post.create(content: '', notify: false) -> It does not create the notification.
        def notify(options = {})
          options[:sender] ||= @@options[:sender]
          options[:receivers] ||= @@options[:receivers]
          if notify_flag.nil? || (!notify_flag.nil? && !!notify_flag)
            raise 'SimpleNotification::SenderReceiverError' unless @@options[:sender] && @@options[:receivers]
            @message = options[:message] if options[:message]
            notification = notifications.build(entity: self, sender: get_obj(options[:sender]), message: default_message(self, get_obj(options[:sender]), 'created'))
            [get_obj(options[:receivers])].flatten.each {|receiver| notification.deliveries.build(receiver: receiver)}
            notification.save
          end
        end

        def flush_notifications
          notifications.destroy_all
        end

        # Check if notifications has already been delivered.
        def notified?
          !notifications.blank?
        end

        def notificants
          SimpleNotifications::Record.includes(deliveries: :receiver)
              .collect(&:deliveries).flatten
              .collect(&:receiver)
        end

        def read_marked_notificants
          SimpleNotifications::Record.includes(deliveries: :receiver)
              .collect(&:deliveries).flatten
              .select{|record| record.is_read}
              .collect(&:receiver)
        end

        def unread_marked_notificants
          SimpleNotifications::Record.includes(deliveries: :receiver)
              .collect(&:deliveries).flatten
              .select{|record| !record.is_read}.collect(&:receiver)
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

        def default_message(entity, sender, action)
          @message || (method(@@options[:notify_message]).call if !!@@options[:notify_message]) || "#{get_obj(sender).class.name} #{action} #{entity.class.name} #{entity.name}."
        end

        private

        def get_obj(sender_or_receivers)
          sender_or_receivers.kind_of?(Symbol) ? send(sender_or_receivers) : sender_or_receivers
        end

        def create_notification
          notify({sender: get_obj(@@options[:sender]), receivers: get_obj(@@options[:receivers]), message: default_message(self, get_obj(@@options[:sender]), 'created')})
        end

        def update_notification
          notify({sender: get_obj(@@options[:sender]), receivers: get_obj(@@options[:receivers]), message: default_message(self, get_obj(@@options[:sender]), 'updated')})
        end

        def destroy_notification
          notify({sender: get_obj(@@options[:sender]), receivers: get_obj(@@options[:receivers]), message: default_message(self, get_obj(@@options[:sender]), 'deleted')})
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
