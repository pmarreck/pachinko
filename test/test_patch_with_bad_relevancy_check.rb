# This is a mock patch for the Pachinko test suite. All it does is add a class.

class Pachinko
  class TestPatchWithBadRelevancyCheck < Pachinko

    PATCH = ->{
      class String
        def completely_new_method
          "it's here"
        end
      end
    }

    def name
      'Non-applicable test patch'
    end

    def relevant?
      true
    end

  end
end
# normally this class would call .run on itself, but the test does this itself in this case.
