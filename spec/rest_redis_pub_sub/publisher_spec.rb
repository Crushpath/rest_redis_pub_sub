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
      my_publisher = double('MyPublisher')
      MyPublisher.stub(:new).and_return(my_publisher)

      expect(my_publisher).to receive(:publish)
      MyPublisher.publish({})
    end

    it "should enqueue the publish if enqueue param is provided" do
      MyPublisher.stub(:background_handler_defined?).and_return(true)
      expect(MyPublisher).to receive(:enqueue_publish!).with({:property => 'awesome'})

      MyPublisher.publish({:property => 'awesome', :enqueue => true})
    end

    it "should raise an error if job has no listeners" do
      my_publisher = double('MyPublisher')
      my_publisher.stub(:publish).and_return(0)
      MyPublisher.stub(:new).and_return(my_publisher)
      MyPublisher.stub(:background_handler_defined?).and_return(true)

      expect {
        MyPublisher.publish({property: 'great', raise_if_no_listeners: true})
      }.to raise_error(RestRedisPubSub::NoListeners)
    end

    it "should enqueue if job has no listeners" do
      my_publisher = double('MyPublisher')
      my_publisher.stub(:publish).and_return(0)
      MyPublisher.stub(:new).and_return(my_publisher)
      MyPublisher.stub(:background_handler_defined?).and_return(true)

      attrs = {property: 'great', raise_if_no_listeners: false}
      MyPublisher.should_receive(:enqueue_publish!).with(attrs)

      MyPublisher.publish(attrs)
    end

    it "should enqueue with delay if job has no listeners" do
      my_publisher = double('MyPublisher')
      my_publisher.stub(:publish).and_return(0)
      MyPublisher.stub(:new).and_return(my_publisher)
      MyPublisher.stub(:background_handler_defined?).and_return(true)
      MyPublisher.stub(:background_delay_defined?).and_return(true)

      attrs = {property: 'great', raise_if_no_listeners: false}
      MyPublisher.should_receive(:enqueue_publish_with_delay).with(attrs)

      MyPublisher.publish(attrs)
    end

  end

end
