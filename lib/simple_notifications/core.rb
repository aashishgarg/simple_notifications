module SimpleNotifications
  module Core
    module Receiver
      def self.included(base)
        puts '$$$$$$$$$$$$$$$$$$$$$$'
        puts base.inspect
        puts '$$$$$$$$$$$$$$$$$$$$$$'
        base.class_eval do
          after_commit :notify, on: :create

          def message(entity, receiver)
            "#{entity.class.name} #{entity.name} created by #{receiver.id}"
          end

          private

          def notify
            puts '&&&&&&&&&&&&&&&&&&&&&&&&'
            puts '&&&&&&&&&&&&&&&&&&&&&&&&'
            puts '&&&&&&&&&&&&&&&&&&&&&&&&'
            puts '&&&&&&&&&&&&&&&&&&&&&&&&'
            # SimpleNotifications::Record.create(entity: @@entity, sender: @@sender, receivers: @@receivers,
            #                                    message: message(@@entity, @@receivers))
          end
        end
      end
    end

    mattr_accessor :entity, :sender, :receivers

    def notify(entity, sender, receivers)
      @@entity = entity
      @@sender = sender
      @@receivers = receivers

      puts '***********************'
      puts @@entity.inspect
      puts Receiver.inspect
      puts '***********************'

      @@entity.class.send(:include, Receiver)
    end
  end

  def self.included(base)
    base.extend Core
    base.class_eval do

      # --- Associations --- #
      has_and_belongs_to_many :received_notifications, class_name: 'SimpleNotifications::Record',
                              join_table: 'notifications_receivers'
      has_many :sent_notifications, class_name: 'SimpleNotifications::Record', as: :sender
      has_many :notification_senders, through: :sent_notifications
      has_many :notification_receivers, through: :received_notifications
    end
  end
end