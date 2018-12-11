require 'simple_notifications/version'
require 'simple_notifications/core'

module SimpleNotifications
  def self.included(base)
    base.extend Core
  end
end

ActiveRecord::Base.send(:include, SimpleNotifications)
