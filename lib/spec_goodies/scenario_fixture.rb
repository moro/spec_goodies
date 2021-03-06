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
        define_method(name) do
          fetch_or_build_fixture(name, builder)
        end
      end

      def reflesh_scenario_fixture(*args)
        after(:each) do
          args.each {|name| self.class.cleanup_scenario_fixture(name) }
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

    private
    def fetch_or_build_fixture(name, builder)
      if var = self.class.fetch_scenario_fixture(name)
        var
      else
        scenario_fixture_data[name] = instance_eval(&builder)
        fetch_or_build_fixture(name, builder)
      end
    end
  end
end
