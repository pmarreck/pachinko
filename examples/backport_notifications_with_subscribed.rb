# Always require all the classes you will be patching (or will need in order to patch) first
require 'active_support/notifications'
# Change the following path to your rails app root directory...
app_root ||= (Rails.root.to_s rescue File.expand_path(File.join(__FILE__, ['..']*4)))
require 'pachinko'

class ActiveSupportNotificationsWithSubscribedPatch < Pachinko

  def name
    'ActiveSupport::Notifications.subscribed'
  end

  def relevant?
    !ActiveSupport::Notifications.methods(false).include?(:subscribed)
  end

  PATCH = ->{
    # monkeypatch "subscribed" method from Rails 4 into ActiveSupport::Notifications (only if it doesn't exist yet)
    module ::ActiveSupport
      module Notifications
        class << self
          def subscribed(callback, *args)
            subscriber = subscribe(*args, &callback)
            yield
          ensure
            unsubscribe(subscriber)
          end
        end
      end
    end
  }

end

ActiveSupportNotificationsWithSubscribedPatch.run(__FILE__==$PROGRAM_NAME)
