require 'simple_notifications/version'
require 'simple_notifications/base'
require 'simple_notifications/notification_actions'
require_relative 'simple_notifications/app/models/simple_notification'
require_relative 'simple_notifications/app/models/delivery'

module SimpleNotifications
  def self.included(base_class)
    base_class.extend Base
  end
end

ActiveRecord::Base.send(:include, SimpleNotifications)
