module SimpleNotifications
  class Delivery < ActiveRecord::Base
    self.table_name = 'deliveries'

    # --- Associations --- #
    belongs_to :simple_notification, class_name: 'SimpleNotifications::Record', inverse_of: :deliveries
    belongs_to :receiver, polymorphic: true
  end
end
