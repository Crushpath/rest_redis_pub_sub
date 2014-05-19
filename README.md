RestRedisPubSub
===============

## Installation

```ruby
gem 'rest_redis_pub_sub'
```

## Configuration

Subscribe to channels using the env var:

```ruby
ENV['RRPS_SUBSCRIBE_TO'] = "channel-one,channel-two"
```

Publish to a default channel:
```ruby
ENV['RRPS_PUBLISH_TO'] = 'channel'
```

For configuring defaults you have to define/load:

```ruby
RestRedisPubSub.configure do |config|
  # Defaults to ENV['RRPS_SUBSCRIBE_TO']
  config.subscribe_to = ['channel-one', 'channel-two']

  # Defaults to ENV['RRPS_PUBLISH_TO']
  config.publish_to = 'other-channel'

  # Set you preferable redis client to handle subscribe and publish.
  config.redis_instance = $redis_instance
end
```

## Running Listener
```bash
bundle exec run rake rest_redis_pub_sub::subscribe
```

## Publish

Using default channel:
```ruby
RestRedisPubSub::Client.post(resource, identifier, data)
```
Or a custom one:
```ruby
client = RestRedisPubSub::Client.new('channel')
client.post(resource, identifier, data)
```

It publish to the specified channel the following data in json format:

```json
=> {
  verb: 'post',
  resource: 'spot',
  type: 'request'
  identifier: '123456',
  data: {}
}
```

## Subscribe

`RestRedisPubSub` will forward all messages received to a class base on the
__verb__ and __resource__ received:

NOTE: This classes should have a namespace...

| Verb   | Resource | Class          |
|--------|----------|----------------|
| post   | spot     | SpotCreated    |
| put    | product  | ProductUpdated |
| delete | user     | UserDeleted    |

An example class that should be defined in the project to handle the publish message:

```ruby
class SpotCreated

  def initialize(data)
    @data = data
  end

  attr_reader :data

  def process
    ...
  end

  def status
    success? :success : :fail
  end

  def response
    {spot: {id: 1}, ...}
  end

end
```

## Respond to the Request

Base on the status of the class, `RestRedisPubSub` can send a __success__ or __fail__ response,
along with the identifier.

```ruby
RestRedisPubSub::Client.success(verb, resource, identifier, response_data)
```-

```json
=> {
  verb: 'post',
  resource: 'spot',
  type: 'response',
  status: 'success/fail'
  identifier: '123456',
  data: {}
}
```

## Handling response / Callbacks

```ruby
class SpotCreatedPublisher

  def publish
    RestRedisPubSub::Client.post(resource, identifier, data)
  end

  def on_success(data)
  end

  def on_failure(data)
  end

end
```
