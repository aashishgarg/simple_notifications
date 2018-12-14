module SimpleNotifications
  class Record < ActiveRecord::Base
    self.table_name = 'simple_notifications'

    # --- Associations --- #
    belongs_to :sender, polymorphic: true
    belongs_to :entity, polymorphic: true
    has_many :deliveries, class_name: 'SimpleNotifications::Delivery', inverse_of: :simple_notification, foreign_key: :simple_notification_id,
             dependent: :destroy

    # --- validations --- #
    validates :message, presence: true, length: {minimum: 1, maximum: 199}

    # --- Callbacks --- #
    after_commit :after_actions, on: :create

    private

    def after_actions

    end
  end
end
