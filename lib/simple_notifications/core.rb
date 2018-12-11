module SimpleNotifications
  module Core
    mattr_accessor :sender, :receivers

    def notify(sender, *receivers)
      @@sender = sender
      @@receivers = receivers.flatten
    end
  end

  def self.included(base)
    base.extend Core
    base.class_eval do
      # --- Attribute Accessors --- #
      attr_accessor :entity_name

      # --- Associations --- #
      has_many :sent_notifications, class_name: 'SimpleNotifications::Record', as: :sender
      has_many :received_notifications, class_name: 'SimpleNotifications::Record', as: :receiver

      has_many :notification_senders, through: :sent_notifications
      has_many :notification_receivers, through: :received_notifications

      # --- Callbacks --- #
      after_commit :notify, on: :create

      private

      def notify
        SimpleNotifications::Core.receivers.each do |receiver|
          SimpleNotifications::Record.create(sender: SimpleNotifications::Core.sender,
                                             receiver: receiver,
                                             entity: self,
                                             message: "Item #{entity_name || id} created by #{SimpleNotifications::Core.sender.id}")
        end
      end
    end
  end
end