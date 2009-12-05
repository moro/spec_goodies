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
            scenario_fixture_data[name] = instance_eval(&builder)
            send name
          end
        end
      end

      def fetch_scenario_fixture(key)
        if k = ScenarioFixture.caching_klass(self, key)
          k.scenario_fixture_data[key]
        else
          nil
        end
      end

      def cleanup_scenario_fixture(key)
        if k = ScenarioFixture.caching_klass(self, key)
          !!k.scenario_fixture_data.delete(key)
        else
          false
        end
      end
    end

    def caching_klass(base_klass, key)
      base_klass.ancestors.detect {|klass|
        next unless (klass.is_a?(Class) && klass.respond_to?(:scenario_fixture_data))
        klass.scenario_fixture_data[key]
      }
    end
    module_function :caching_klass

    def fetch_scenario_fixture(key)
      self.class.fetch_scenario_fixture(key)
    end
  end
end
