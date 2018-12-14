module SimpleNotifications
  module Base
    mattr_accessor :notified_flag, :entity, :sender, :receivers, :is_sender_receiver_associated

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

    # Starts the notification functionality on the Model.
    def notify(options = {})
      @@sender = options[:sender]
      @@receivers = options[:receivers]
      raise 'SimpleNotifications::SenderReceiversError' unless notification_validated?
      define_associations
      self.class_eval do
        after_create_commit :create_notification

        private

        def message(entity, sender)
          "#{entity.class.name} #{entity.name} created by #{sender.id}"
        end

        def create_notification
          SimpleNotifications::Record.create(entity: self, sender: @@sender, receivers: @@receiver, message: message(self, @@sender))
        end
      end

      @@notified_flag = true
    end

    def sender_receiver_classes
      [@@sender.class, @@receivers.collect(&:class)].flatten.uniq
    end

    def define_associations
      sender_receiver_classes.each do |base|
        base.class_eval do
            has_many :deliveries, class_name: 'SimpleNotifications::Delivery', as: :receiver
            has_many :sent_notifications, class_name: 'SimpleNotifications::Record', as: :sender
            has_many :notification_senders, through: :sent_notifications
            has_many :notification_receivers, through: :received_notifications
        end
      end
    end
  end
end

# Rails.application.eager_load!
# Product.notified?
