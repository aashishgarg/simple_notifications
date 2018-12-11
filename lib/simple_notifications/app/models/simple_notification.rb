module SimpleNotifications
  class Record < ActiveRecord::Base
    self.table_name = 'simple_notifications'

    # --- Associations --- #
    belongs_to :receiver, polymorphic: true
    belongs_to :sender, polymorphic: true
    belongs_to :entity, polymorphic: true

    # --- validations --- #
    validates :message, presence: true, length: {minimum: 1, maximum: 199}

    # --- Callbacks --- #
    after_commit :after_actions, on: :create

    private

    def after_actions

    end
  end
end
