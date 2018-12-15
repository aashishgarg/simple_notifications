module SimpleNotifications
  class Delivery < ActiveRecord::Base
    self.table_name = 'deliveries'

    # Class Attribute Accessors
    cattr_accessor :after_delivered, :after_read

    # Associations
    belongs_to :simple_notification,
               class_name: 'SimpleNotifications::Record',
               inverse_of: :deliveries
    belongs_to :receiver, polymorphic: true

    # Callbacks
    after_update_commit :after_create_actions

    private

    def after_create_actions
      if !!SimpleNotifications::Delivery.after_delivered && previous_changes['is_delivered'] == [false, true]
        SimpleNotifications::Delivery.after_delivered.call
      end

      if !!SimpleNotifications::Delivery.after_read && previous_changes['is_read'] == [false, true]
        SimpleNotifications::Delivery.after_read.call
      end
    end
  end
end
