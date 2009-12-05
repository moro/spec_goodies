require 'spec_goodies/scenario_fixture'

describe SpecGoodies::ScenarioFixture do
  class ExampleGroupKlass
    include SpecGoodies::ScenarioFixture
  end

  class SubClass_1 < ExampleGroupKlass
  end

  class SubClass_1_1 < SubClass_1
  end

  class SubClass_2 < ExampleGroupKlass
  end

  before do
    @mock = mock = mock("counter")
    @data = data = "the_data"
    ExampleGroupKlass.scenario_fixture(:the_data) do
      mock.invoke
      data
    end
    @example_group = ExampleGroupKlass.new
  end
  subject { @example_group }

  it { should respond_to(:the_data) }
  it "block is yield one and only once" do
    @mock.should_receive(:invoke).once
    @example_group.the_data.should == "the_data"
  end
end

