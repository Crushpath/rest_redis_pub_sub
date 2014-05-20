RestRedisPubSub
===============

## Installation

```ruby
gem 'rest_redis_pub_sub'
```

## Configuration

Subscribe to channels using the env var:

```ruby
ENV['RRPS_SUBSCRIBE_TO'] = 'my-app-channel'
```

Publish to a default channel:
```ruby
ENV['RRPS_PUBLISH_TO'] = 'interested-channels'
```

For configuring defaults you have to define/load:

```ruby
RestRedisPubSub.configure do |config|
  # Defaults to ENV['RRPS_SUBSCRIBE_TO']
  config.subscribe_to = ['my-app-channel']

  # Defaults to ENV['RRPS_PUBLISH_TO']
  config.publish_to = 'interested-channels'

  # Set you preferable redis client to handle subscribe and publish.
  config.redis_instance = $redis_instance

  # Set this if your listeners will be inside a namespace.
  config.listeners_namespace = MyListeners::Namespace

  # Set publish generator
  config.publisher = 'my-app'
end
```

## Running Listener
```bash
bundle exec run rake rest_redis_pub_sub:subscribe
```

## Publish

Using default channel:
```ruby
RestRedisPubSub::Client.publish(created, resource, identifier, data)
```
Or a custom one:
```ruby
client = RestRedisPubSub::Client.new('channel')
client.publish(created, resource, identifier, data)
```

It publish to the specified channel the following data in json format:

```json
=> {
  publisher: 'my-app'
  event: 'created',
  resource: 'spot',
  id: 'spot_id',
  data: {}
}
```

## Subscribe

`RestRedisPubSub` will forward all messages received to a class base on the
__event__ and __resource__ received:

| Event   | Resource | Class          |
|---------|----------|----------------|
| created | spot     | SpotCreated    |
| updated | product  | ProductUpdated |
| delated | user     | UserDeleted    |

An example class that should be defined in the project to handle the publish message:

```ruby
class SpotCreated

  def initialize(id, data)
  end

end
```
