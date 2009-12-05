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

  Spec::Matchers.define :be_identical_with do |actual|
    match do |expect|
      actual.equal?(expect)
    end
  end

  before do
    @mock = mock = mock("counter")
    SubClass_1.scenario_fixture(:the_data) do
      mock.invoke
      "the_data"
    end
    @parent_sub_obj = SubClass_1.new
  end
  subject { @parent_sub_obj }

  it { should respond_to(:the_data) }

  describe "block is yield one and only once" do
    before do
      @mock.should_receive(:invoke).at_most(1).times
    end
    subject { @parent_sub_obj.the_data }

    it { should == "the_data" }

    specify "even if the method called  at most 1 times." do
      3.times{ @parent_sub_obj.the_data }
    end
  end

  describe "cleanup" do
    before do
      @mock.should_receive(:invoke).twice
      SubClass_1.cleanup_scenario_fixture(:the_data)
      @original = @parent_sub_obj.the_data # once
      SubClass_1.cleanup_scenario_fixture(:the_data)
    end
    subject { @parent_sub_obj.the_data }

    it "returns same data" do
      should == @original
    end

    it { should_not be_identical_with @original }
  end

  describe "other instance / for same level 'it'" do
    before do
      @mock.stub!(:invoke).once
      @other_instance = SubClass_1.new
    end
    subject { @other_instance.the_data }
    it { should be_identical_with @parent_sub_obj.the_data }
  end

  describe "inheritance" do
    before do
      @mock.stub!(:invoke)
      @child = SubClass_1_1.new
    end
    subject { @child.the_data }
    it { should be_identical_with @parent_sub_obj.the_data }
  end

  describe "not inherited" do
    before do
      @non_inherit = SubClass_2.new
    end
    subject { @non_inherit }
    it { should_not respond_to(:the_data) }
  end
end

