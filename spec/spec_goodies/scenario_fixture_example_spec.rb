require 'spec_helper'

describe "ScenarioFixture Sample" do
  describe "definition" do
    scenario_fixture(:high_cost_object) do
      "high_cost_object"
    end

    before do
      $high_cost_object ||= high_cost_object
    end
    subject { high_cost_object }
    it { should be_identical_with $high_cost_object }

    describe "read-only-pattern" do
      subject { high_cost_object }
      3.times { it { should be_identical_with $high_cost_object } }

      describe "nesting" do
        3.times { it { should be_identical_with $high_cost_object } }
      end
    end

    describe "write" do
      reflesh_scenario_fixture :high_cost_object

      specify "the 1st test uses read-only test" do
        high_cost_object.should be_identical_with $high_cost_object
      end

      specify "the 2nd test should not identical with $high_cost_object" do
        $second_object = high_cost_object
        $second_object.should_not be_identical_with $high_cost_object
      end

      specify "the 3rd test should not identical with 2nd" do
        $third_object = high_cost_object
        $third_object.should_not be_identical_with $second_object
      end
    end

    describe "retry read attr should_not identical_with last(write-3rd)" do
      it { high_cost_object.should_not be_identical_with $third_object }
    end
  end
end

