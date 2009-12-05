module SpecGoodies
  module ScenarioFixture
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def scenario_fixture(name, &builder)
        define_method(name, &builder)
      end
    end
  end
end
