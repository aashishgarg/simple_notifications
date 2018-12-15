module SimpleNotifications
  class Record < ActiveRecord::Base
    self.table_name = 'simple_notifications'

    # Class Attribute Accessors
    cattr_accessor :before_notify, :after_notify

    # Associations
    belongs_to :sender, polymorphic: true
    belongs_to :entity, polymorphic: true
    has_many :deliveries, class_name: 'SimpleNotifications::Delivery',
             inverse_of: :simple_notification,
             foreign_key: :simple_notification_id,
             dependent: :destroy
    has_many :read_deliveries, -> {where(is_read: true)},
             class_name: 'SimpleNotifications::Delivery',
             inverse_of: :simple_notification,
             foreign_key: :simple_notification_id,
             dependent: :destroy
    has_many :unread_deliveries, -> {where(is_read: false)},
             class_name: 'SimpleNotifications::Delivery',
             inverse_of: :simple_notification,
             foreign_key: :simple_notification_id,
             dependent: :destroy

    # Scopes
    scope :read, -> {where(is_read: true)}
    scope :unread, -> {where.not(is_read: true)}

    # Validations
    validates :message, presence: true, length: {minimum: 1, maximum: 199}

    # Callbacks
    before_create :before_actions
    after_create_commit :after_actions

    private

    def before_actions
      SimpleNotifications::Record.before_notify.call if !!SimpleNotifications::Record.before_notify
    end

    def after_actions
      SimpleNotifications::Record.after_notify.call if !!SimpleNotifications::Record.after_notify
    end
  end
end
