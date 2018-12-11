module SimpleNotifications
  module Core
    def notify

    end
  end

  def self.included(base)
    base.extend Core
    base.class_eval do
      # --- Associations --- #
      has_many :sent_notifications, class_name: 'SimpleNotifications::Record', as: :sender
      has_many :received_notifications, class_name: 'SimpleNotifications::Record', as: :receiver

      # --- validations --- #


      # --- Callbacks --- #

    end
  end
end