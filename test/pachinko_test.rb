require 'test/unit'
require 'active_support/core_ext'
require 'mocha/setup'
require 'pathname'

module Rails
  def self.env
    @env ||= ActiveSupport::StringInquirer.new('test')
  end unless defined?(env)
  def self.root
    @root ||= Pathname.new(File.expand_path(File.join(__FILE__, ['..']*5)))
  end unless defined?(root) && root
end

require_relative '../lib/pachinko'

require_relative "valid_test_patch"
require_relative "test_patch_with_bad_relevancy_check"

class PachinkoTest < Test::Unit::TestCase

  SUCCESS_OUTPUT_ENV_MAPPING = {
    test: false, development: true, qa: false, production: false
  }
  WARNING_OUTPUT_ENV_MAPPING = {
    test: true, development: true, qa: true, production: true
  }

  def setup
    Pachinko.send(:remove_const, :FabricatedClass) if defined?(Pachinko::FabricatedClass)
    Pachinko.stubs(:mute?).returns(true)
  end

  def test_valid_patch_application
    patch = Pachinko::ValidTestPatch.new
    patch.expects(:success_message)
    patch.run
    assert defined?(::Pachinko::FabricatedClass), "The test patch did not define a FabricatedClass"
  end

  def test_patch_application_failed
    Pachinko::ValidTestPatch.new.run
    rerun_patch = Pachinko::ValidTestPatch.new
    rerun_patch.expects(:patch_not_applied_message)
    run_patch = rerun_patch.run
    assert !run_patch.success?
  end

  def test_validity_check_invalid
    lazy_programmer_patch = Pachinko::TestPatchWithBadRelevancyCheck.new
    lazy_programmer_patch.expects(:relevancy_assertion_wrong_message)
    run_patch = lazy_programmer_patch.run
    assert run_patch.applied?, "Patch wasn't applied despite its invalid check for relevancy"
    assert !run_patch.success?, "Patch with invalid check was also not successfully applied"
  end

  def test_output_success_in_correct_envs
    SUCCESS_OUTPUT_ENV_MAPPING.each do |env, expects_output|
      setup
      Pachinko.stubs(:mute?).returns(false)
      Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new(env.to_s))
      patch = Pachinko::ValidTestPatch.new
      expects_output ? patch.expects(:log_success).once : patch.expects(:log_success).never
      patch.run
    end
  end

  def test_output_warning_in_correct_envs
    WARNING_OUTPUT_ENV_MAPPING.each do |env, expects_output|
      setup
      Pachinko.stubs(:mute?).returns(true)
      Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new(env.to_s))
      patch = Pachinko::TestPatchWithBadRelevancyCheck.new
      expects_output ? patch.expects(:log_warning).once : patch.expects(:log_warning).never
      patch.run
    end
  end

end
