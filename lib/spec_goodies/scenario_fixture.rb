require 'active_support'

module SpecGoodies
  module ScenarioFixture
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def self.extended(base)
        base.class_inheritable_hash :scenario_fixture_data
        base.scenario_fixture_data = {}.with_indifferent_access
      end

      def scenario_fixture(name, &builder)
        define_method(name) do |*args|
          if var = fetch_scenario_fixture(name)
            var
          else
            self.class.scenario_fixture_data[name] = instance_eval(&builder)
            send name
          end
        end
      end

      def fetch_scenario_fixture(name)
        klass = ancestors.detect {|klass|
          next unless (klass.is_a?(Class) && klass.respond_to?(:scenario_fixture_data))
          klass.scenario_fixture_data[name]
        }
        klass ? klass.scenario_fixture_data[name] : nil
      end
    end

    def fetch_scenario_fixture(name)
      self.class.fetch_scenario_fixture(name)
    end
  end
end
