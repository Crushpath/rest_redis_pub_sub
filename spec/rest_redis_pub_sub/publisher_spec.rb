require 'spec_helper'

describe RestRedisPubSub::Publisher do

  before do
    class MyPublisher < described_class
      def initialize(attrs={})
      end
    end
  end

  it "should raise an error for required fields" do
    @my_publisher = MyPublisher.new
    expect{ @my_publisher.verb }.to raise_error(NotImplementedError)
    expect{ @my_publisher.actor }.to raise_error(NotImplementedError)
    expect{ @my_publisher.object }.to raise_error(NotImplementedError)
  end

  it "should not raise an error for optional fields" do
    @my_publisher = MyPublisher.new
    expect{ @my_publisher.id }.to_not raise_error(NotImplementedError)
    expect{ @my_publisher.target }.to_not raise_error(NotImplementedError)
    expect{ @my_publisher.source }.to_not raise_error(NotImplementedError)
    expect{ @my_publisher.extensions }.to_not raise_error(NotImplementedError)
  end

  describe ".publish" do
    it "should call publish on the instance" do
      my_publisher = described_class.new
      MyPublisher.stub(:new).and_return(my_publisher)

      expect(my_publisher).to receive(:publish)
      MyPublisher.publish({})
    end


    describe "persist", focus: true do
      before do
        @my_publisher = described_class.new
        MyPublisher.stub(:new).and_return(@my_publisher)
        @my_publisher.stub(:persist).and_return(true)
      end
      it "should publish" do
        expect(@my_publisher).to receive(:publish)
        MyPublisher.publish({})
      end
    end

    it "should enqueue the publish if enqueue param is provided" do
      MyPublisher.stub(:background_handler_defined?).and_return(true)
      expect(MyPublisher).to receive(:enqueue_publish!).with({:property => 'awesome'})

      MyPublisher.publish({:property => 'awesome', :enqueue => true})
    end

    context "when no listeners" do
      before do
        my_publisher = described_class.new
        my_publisher.stub(:publish).and_return(0)
        MyPublisher.stub(:new).and_return(my_publisher)
        MyPublisher.stub(:background_handler_defined?).and_return(true)
      end

      it "should enqueue at first failure" do
        attrs = {property: 'great', raise_if_no_listeners: false}
        MyPublisher.should_receive(:enqueue_publish!).with(attrs)
        MyPublisher.publish(attrs)
      end

      it "should enqueue with delay at second failure" do
        MyPublisher.stub(:background_delay_defined?).and_return(true)

        attrs = {property: 'great', raise_if_no_listeners: false}
        MyPublisher.should_receive(:enqueue_publish_with_delay).with(attrs)

        MyPublisher.publish(attrs)
      end

      it "should raise an error at third failure" do
        expect {
          MyPublisher.publish({property: 'great', raise_if_no_listeners: true})
        }.to raise_error(RestRedisPubSub::NoListeners)
      end

    end
  end

  describe "#valid" do
    before do
      @my_publisher = described_class.new
      MyPublisher.stub(:new).and_return(@my_publisher)
    end

    it 'should publish when publisher is valid' do
      @my_publisher.stub(:valid?).and_return(true)
      expect(@my_publisher).to receive(:publish)
      MyPublisher.publish({})
    end

    it "should abort publish when publisher is not valid" do
      @my_publisher.stub(:valid?).and_return(false)
      expect(@my_publisher).to_not receive(:publish)
      MyPublisher.publish({})
    end

  end

end
