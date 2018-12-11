module SimpleNotifications
  class Record < ActiveRecord::Base
    self.table_name = 'simple_notifications'

    # --- Associations --- #
    belongs_to :receiver, polymorphic: true
    belongs_to :sender, polymorphic: true

    # --- validations --- #
    validates :message, presence: true, length: {minimum: 1, maximum: 199}
  end
end
