require 'ansi'

# A little helper to manage patch application and warn if it looks no longer necessary

# Example format of a patch:
# class YourPatch < Pachinko
#   # name: any string naming this patch
#   def name
#     'Example Patch Creating FabricatedClass'
#   end
#   # relevant?: a method that returns true only if the patch needs to be applied
#   def relevant?
#     !defined?(FabricatedClass)
#   end
#   # patch: a method which you pass a block which applies the patch
#   # Reason for this is that you can't reopen classes in methods...
#   patch do
#     class ::FabricatedClass; end
#   end
# end

class Pachinko

  attr_reader :results

  def success?
    @success
  end

  def applied?
    @applied
  end

  def self.mute?
    ENV['MUTE_PACHINKO']
  end

  class << self
    attr_accessor :last_patch
    attr_reader :patch_block

    def patch(&block)
      @patch_block = block
    end

    def run(*args)
      new.run(*args)
    end

    def development_mode?
      defined?(::Rails) && defined?(::Rails.env) && ::Rails.env.development?
    end

    def test_mode?
      if defined?(::Rails) && defined?(::Rails.env)
        ::Rails.env.test?
      else
        true
      end
    end

    def last_results
      last_patch.results
    end
  end

  def name
    raise NotImplementedError, "Your patch doesn't define a 'name' method... please override in your patch class"
  end

  # This method returns a boolean that actually checks the mechanics of whatever the patch is supposed to fix.
  # It should return true if the patch still needs to be applied, and false after it has been applied or if it doesn't need to be applied.
  def relevant?
    raise NotImplementedError, "Your patch doesn't define a 'relevant?' method which tests whether it is necessary... please override in your patch class"
  end

  # Overridable in subclasses, although not recommended
  # Should return true if the patch was applied (which in most cases means it's also no longer applicable)
  def irrelevant?
    !relevant?
  end

  def run(force_plain_output = false)
    @force_plain_output = force_plain_output
    @success = false
    @applied = false
    output_msgs = []
    output_msgs_warning = []
    if relevant?
      apply
      @applied = true
      # Check to see if the patch is no longer needed (i.e., the test is valid, and the patch worked)
      if irrelevant?
        output_msgs << success_message
        @success = true
      else
        output_msgs_warning << relevancy_assertion_wrong_message
      end
    else
      output_msgs_warning << patch_not_applied_message
    end
    if !output_msgs.empty? && (Pachinko.development_mode? || force_plain_output)
      log_success output_msgs.join("\n") unless Pachinko.mute?
    end
    if !output_msgs_warning.empty?
      log_warning output_msgs_warning.join("\n")
    end
    Pachinko.last_patch = self
    @results = output_msgs_warning | output_msgs
    self
  end

  private
  def apply
    begin
      self.class.patch_block.call
    rescue NameError => e
      e.message << "\nNOTE TO PATCH DEVS: If you are writing a patch, it is possible that you just have to root-namespace any relevant classes in your PATCH block with a double colon (::) in front, to avoid this error!"
      raise e
    end
  end
  def log(out)
    unless out.empty?
      Rails.logger.info(out) if defined?(Rails) && defined?(Rails.logger) rescue nil
      puts out
    end
  end
  alias log_success log
  alias log_warning log
  def ansi(color, text)
    if @force_plain_output # don't colorize
      text
    else
      ANSI.send(color){ text }
    end
  end
  def success_message
    "#{ansi :yellow, 'Patch'} #{ansi :bold, self.class.to_s} applied"
  end
  def caution_prelude
    "#{ansi :red, 'CAUTION'}: #{ansi :yellow, 'Patch'} #{ansi :bold, self.class.to_s} "
  end
  def relevancy_assertion_wrong_message
    caution_prelude << "either wasn't applied correctly or the test code for its necessity is wrong!"
  end
  def patch_not_applied_message
    caution_prelude << "NOT applied! (test for necessity was false)"
  end

end

########## inline test running
if __FILE__==$PROGRAM_NAME
  require_relative '../test/pachinko_test'
end
