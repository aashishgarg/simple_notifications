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
    before_update :before_read, if: proc {!!SimpleNotifications::Base.options[:before_read] && changes['is_read'] == [false, true]}
    before_update :before_delivered, if: proc {!!SimpleNotifications::Base.options[:before_delivered] && changes['is_delivered'] == [false, true]}
    after_update_commit :after_read, if: proc {!!SimpleNotifications::Base.options[:after_read] && previous_changes['is_read'] == [false, true]}
    after_update_commit :after_delivered, if: proc {!!SimpleNotifications::Base.options[:after_delivered] && previous_changes['is_delivered'] == [false, true]}

    def entity
      simple_notification.entity
    end

    private

    %w(read delivered).each do |update_type|
      define_method("before_#{update_type}") do
        call_method(SimpleNotifications::Base.options["before_#{update_type}".to_sym])
      end

      define_method("after_#{update_type}") do
        call_method(SimpleNotifications::Base.options["after_#{update_type}".to_sym])
      end
    end

    def call_method(_method)
      if _method.class == Symbol
        entity.method(_method).call if entity.class.instance_methods(false).include?(_method)
      elsif _method.class == Proc
        _method.call
      end
    end
  end
end
