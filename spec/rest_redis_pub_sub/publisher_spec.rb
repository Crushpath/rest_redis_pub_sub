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

end
