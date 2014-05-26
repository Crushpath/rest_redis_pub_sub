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
      MyAppProductCreate = Class.new
      handler = RestRedisPubSub::EventHandler.new(
        'generator' => {'display_name' => 'my_app'},
        'verb' => 'create',
        'activity_type' => 'product_create'
      )
      expect(handler.class_to_forward).to eq(MyAppProductCreate)
    end

    it "should return nil if class doesnt exists" do
      handler = RestRedisPubSub::EventHandler.new(
        'generator' => {'display_name' => 'my_app'},
        'verb' => 'update',
        'activity_type' => 'product_update'
      )
      expect(handler.class_to_forward).to be_nil
    end

    it "should consider listener_namespace if set" do
      MyListeners = Module.new
      MyListeners::MyAppProductDelete = Class.new

      RestRedisPubSub.listeners_namespace = MyListeners
      handler = RestRedisPubSub::EventHandler.new(
        'generator' => {'display_name' => 'my_app'},
        'verb' => 'delete',
        'activity_type' => 'product_delete'
      )
      expect(handler.class_to_forward).to eq(MyListeners::MyAppProductDelete)
    end
  end

end
