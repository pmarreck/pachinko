# Always require all the classes you will be patching (or will need in order to patch) first
require 'active_support/duration'
require 'active_support/core_ext/time/conversions'
require 'active_support/time_with_zone'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'

# Change the following path to your rails app root directory...
app_root ||= (Rails.root.to_s rescue File.expand_path(File.join(__FILE__, ['..']*4)))
require 'pachinko'

# Backports monkeypatch to fix Time.at bug from https://github.com/rails/rails/pull/10686
class ActiveSupportTimeWithZoneWithToIntPatch < Pachinko

  def name
    'ActiveSupport::TimeWithZone#to_int'
  end

  def relevant?
    old_time_zone = Time.zone
    begin
      Time.zone = 'EST'
      Time.at(Time.zone.now)
      false
    rescue TypeError
      true
    ensure
      Time.zone = old_time_zone
    end
  end

  patch do
    class ::Time
      class << self
        # Layers additional behavior on Time.at so that ActiveSupport::TimeWithZone and DateTime
        # instances can be used when called with a single argument
        def at_with_coercion(*args)
          if args.size == 1 && args.first.acts_like?(:time)
            at_without_coercion(args.first.to_i)
          else
            at_without_coercion(*args)
          end
        end
        alias_method :at_without_coercion, :at
        alias_method :at, :at_with_coercion
      end
    end
  end

end

ActiveSupportTimeWithZoneWithToIntPatch.run(__FILE__==$PROGRAM_NAME)
