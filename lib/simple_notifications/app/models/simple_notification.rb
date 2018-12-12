module SimpleNotifications
  class Record < ActiveRecord::Base
    self.table_name = 'simple_notifications'

    # --- Associations --- #
    belongs_to :sender, polymorphic: true
    belongs_to :entity, polymorphic: true

    has_and_belongs_to_many :receivers, join_table: 'notifications_receivers'

    # --- validations --- #
    validates :message, presence: true, length: {minimum: 1, maximum: 199}

    # --- Callbacks --- #
    after_commit :after_actions, on: :create

    private

    def after_actions

    end
  end
end
