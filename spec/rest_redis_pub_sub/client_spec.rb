require 'spec_helper'

describe RestRedisPubSub::Client do
  before do
    @redis_instance = double('redis_instance')
    RestRedisPubSub.redis_instance = @redis_instance
    RestRedisPubSub.publisher = 'my-app'
    @expected_data = {
      publisher: RestRedisPubSub.publisher,
      resource: 'resource',
      identifier: 'resource-id',
      data: {name: 'resource-name'}
    }
  end

  describe ".created" do
    it "publish a created event for the given resource" do
      json_message = @expected_data.merge(event: :created).to_json
      expect(@redis_instance).to receive(:publish).with('my-app-resource', json_message)

      client = RestRedisPubSub::Client.new('my-app-resource')
      client.created('resource', 'resource-id', {name: 'resource-name'})
    end
  end

end
