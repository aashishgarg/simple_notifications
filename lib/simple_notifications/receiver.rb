module SimpleNotifications
  module Receiver
    def self.included(base)
      base.class_eval do
        after_commit :notify, on: :create

        def message(notify_for, notify_to)
          "#{notify_for.class.name} #{notify_for.name} created by #{notify_to.id}"
        end

        private

        def notify
          SimpleNotifications::Record.create(entity: @@notify_for, sender: @@notification_by, receivers: @@notify_to,
                                             message: message(@@notify_for, @@notify_to))
        end
      end
    end
  end
end