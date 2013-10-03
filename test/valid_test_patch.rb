# This is a mock patch for the Pachinko test suite. All it does is add a class.

class Pachinko
  class ValidTestPatch < Pachinko

    PATCH = ->{ Pachinko::FabricatedClass = Class.new }

    def name
      'valid_test_patch'
    end

    def relevant?
      !defined?(::Pachinko::FabricatedClass)
    end

  end
end
# normally this class would call .run on itself, but the test does this itself in this case.
