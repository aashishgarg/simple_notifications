module SimpleNotifications
  class CopyModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../lib/simple_notifications/app/models', __dir__)

    def copy_notification_model
      copy_file "simple_notifications.rb", "app/models/simple_notifications.rb"
    end

    def copy_delivery_model
      copy_file "deliver.rb", "app/models/deliver.rb"
    end
  end
end
