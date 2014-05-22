require 'spec_helper'

describe RestRedisPubSub::ResourceSubscriber do

  describe "#initialize" do
    it "should succeed if all required attrs are present" do
      expect{
        described_class.new(app: 'crushpath', resource: 'spot', id: 1234)
      }.not_to raise_error
    end

    it "should fail if required attrs are missing" do
      expect{
        described_class.new(resource: 'spot', id: 1234)
      }.to raise_error(KeyError)

      expect{
        described_class.new(app: 'crushpath', id: 1234)
      }.to raise_error(KeyError)

      expect{
        described_class.new(app: 'crushpath', resource: 'spot')
      }.to raise_error(KeyError)
    end
  end

  describe "#resource_key" do
    it "should return the correct key" do
      subscriber = described_class.new(app: 'crushpath', resource: 'spot', id: 1234)
      expect(subscriber.resource_key).to eq("subscriptions:crushpath:spot:1234")
    end
  end

  describe "#subscribe" do
    it "should add current app to the resource subscribers list" do

    end
  end

end
