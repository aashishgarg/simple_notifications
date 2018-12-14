module SimpleNotifications
  module Base
    mattr_accessor :notified_flag, :sender, :receivers

    #Getter to check if model is enabled with notifications
    def notified?
      !!@@notified_flag
    end

    def notification_validated?
      validate_sender! && validate_receivers!
    end

    # Returns If Sender is not valid Else message
    def validate_sender!
      @@sender.to_s.in?(self.reflections.keys) || @@sender.kind_of?(ActiveRecord::Base)
    end

    # Returns If Receiver is not valid Else message
    def validate_receivers!
      @@receivers.to_s.in?(self.reflections.keys) || @@receivers.kind_of?(ActiveRecord::Relation) || @@receivers.kind_of?(ActiveRecord::Base) || self.methods(false)
    end

    # Add this method to any model and it starts the notification functionality on the Model.
    # Expects two parameters :sender and :receiver.
    def notify(options = {})
      @@sender = options[:sender]
      @@receivers = options[:receivers]
      raise 'SimpleNotifications::SenderReceiversError' unless notification_validated?

      add_sender_class_features
      add_receiver_class_features
      add_notified_class_features

      @@notified_flag = true
    end

    def add_sender_class_features
      # Define association for sender model
      @@sender.class.class_eval do
        has_many :sent_notifications, class_name: 'SimpleNotifications::Record', as: :sender
      end unless @@sender.class == NilClass
    end

    def add_receiver_class_features
      # Define association for receiver model
      @@receivers.collect(&:class).flatten.uniq.each do |base|
        base.class_eval do
          has_many :deliveries, class_name: 'SimpleNotifications::Delivery', as: :receiver
          has_many :received_notifications, through: :deliveries, source: :simple_notification
        end unless base.class == NilClass
      end
    end

    def add_notified_class_features
      self.class_eval do
        attr_accessor :message, :notify
        # Define association for the notified model
        has_many :notifications, class_name: 'SimpleNotifications::Record', as: :entity
        has_many :notifiers, through: :notifications, source: :sender, source_type: @@sender.class.name
        has_many :notificants, through: :notifications, source: :receivers
        has_many :read_deliveries, through: :notifications, source: :read_deliveries
        has_many :unread_deliveries, through: :notifications, source: :unread_deliveries
        has_many :read_notificants, through: :read_deliveries, source: :receiver, source_type: 'User'
        has_many :unread_notificants, through: :unread_deliveries, source: :receiver, source_type: 'User'

        after_create_commit :create_notification, if: proc { @notify.nil? || !!@notify }
        after_update_commit :update_notification, if: proc { @notify.nil? || !!@notify }

        def notified?
          !notifications.blank?
        end

        private

        def default_message(entity, sender, action)
          @message || "#{entity.class.name} #{entity.name} #{action}."
        end

        def create_notification
          notification = SimpleNotifications::Record.new(entity: self, sender: @@sender, message: default_message(self, @@sender, 'created'))
          @@receivers.each {|receiver| notification.deliveries.build(receiver: receiver)}
          notification.save
        end

        def update_notification
          notification = SimpleNotifications::Record.new(entity: self, sender: @@sender, message: default_message(self, @@sender, 'updated'))
          @@receivers.each {|receiver| notification.deliveries.build(receiver: receiver)}
          notification.save
        end
      end
    end
  end
end
