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
    scope :read, -> {joins(:deliveries).where('deliveries.is_read is (?)', true)}
    scope :unread, -> {joins(:deliveries).where('deliveries.is_read is (?)', false)}
    scope :delivered, -> {joins(:deliveries).where('deliveries.is_delivered is (?)', true)}
    scope :undelivered, -> {joins(:deliveries).where('deliveries.is_delivered is (?)', false)}


    # Validations
    validates :message, presence: true, length: {minimum: 1, maximum: 199}

    # Callbacks
    before_create :before_actions
    after_create_commit :after_actions

    private

    %w(before after).each do |call_type|
      define_method("#{call_type}_actions".to_sym) do
        _method = SimpleNotifications::Base.send(:options)["#{call_type}_notify".to_sym]
        if _method.present?
          if _method.class == Symbol
            entity.method(_method).call if entity.class.instance_methods(false).include?(_method)
          elsif _method.class == Proc
            _method.call
          end
        end
      end
    end
  end
end
