RestRedisPubSub
===============

RestRedisPubSub is a small library for publishing, subscribing and handling messages
via Redis pub/sub. It use conventions to simplify configuration.

## Installation

```ruby
gem 'rest_redis_pub_sub'
```

## Configuration

For configuring defaults you have to define/load:

```ruby
RestRedisPubSub.configure do |config|

  config.subscribe_to = ['my-app-channel']

  # It defaults to #{publisher}.#{resource}
  config.publish_to = 'interested-channel'

  # Set you preferable redis client to handle subscribe and publish.
  config.redis_instance = $redis_instance

  # Set this if your listeners will be inside a namespace.
  config.listeners_namespace = MyListeners::Namespace

  # Set publish generator
  config.publisher = 'my-app'
end
```

## Running the worker

Include `rest_redis_pub_sub/tasks` in you application:
```
require 'rest_redis_pub_sub/tasks'
```

Run the worker:

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

The class must implement a class method `.perform`. If `Resque` is defined it will
enqueue it.

An example class that should be defined in the project to handle the publish message:

```ruby
class SpotCreated

  def self.perform(id, data)
    ...
  end

end
```
