module SimpleNotifications
  class CopyModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../simple_notifications/app/models', __dir__)

    def copy_notification_model
      copy_file "simple_notification.rb", "app/models/simple_notification.rb"
    end

    def copy_delivery_model
      copy_file "delivery.rb", "app/models/delivery.rb"
    end
  end
end
