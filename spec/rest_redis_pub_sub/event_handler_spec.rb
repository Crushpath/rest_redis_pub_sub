require 'spec_helper'

describe RestRedisPubSub::EventHandler do

  describe "#forward" do
    before do
      @forwarded_class = double('ResourceEvent')
    end

    it "should call #perform on class to forward" do
      handler = RestRedisPubSub::EventHandler.new
      handler.stub(:class_to_forward).and_return(@forwarded_class)
      @forwarded_class.should_receive(:perform)

      handler.forward
    end

    it "should enqueue it if background class is defined" do
      handler = RestRedisPubSub::EventHandler.new
      handler.stub(:class_to_forward).and_return(@forwarded_class)
      handler.stub(:enqueue_forward?).and_return(true)
      handler.should_receive(:forward_in_background)
      handler.forward
    end
  end

  describe "#class_to_forward" do
    it "should retrieve the proper class if exists" do
      ProductCreated = Class.new
      handler = RestRedisPubSub::EventHandler.new(event: 'created', resource: 'product')
      expect(handler.class_to_forward).to eq(ProductCreated)
    end

    it "should return nil if class doesnt exists" do
      handler = RestRedisPubSub::EventHandler.new(event: 'updated', resource: 'product')
      expect(handler.class_to_forward).to be_nil
    end

    it "should consider listener_namespace if set" do
      MyListeners = Module.new
      MyListeners::ProductDeleted = Class.new

      RestRedisPubSub.listeners_namespace = MyListeners
      handler = RestRedisPubSub::EventHandler.new(event: 'deleted', resource: 'product')
      expect(handler.class_to_forward).to eq(MyListeners::ProductDeleted)
    end
  end

end
