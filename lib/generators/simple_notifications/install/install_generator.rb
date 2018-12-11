module SimpleNotifications
  class InstallGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/simple_notifications.rb"
    end

    def create_migration_file
      copy_file "migration.rb", "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_simple_notifications.rb"
    end
  end
end
