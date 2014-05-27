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

  # It defaults to #{generator}.#{resource}
  config.publish_to = 'interested-channel'

  # Set you preferable redis client to handle subscribe and publish.
  config.redis_instance = $redis_instance

  # Set this if your listeners will be inside a namespace.
  config.listeners_namespace = MyListeners::Namespace

  # Set publish generator
  config.generator = 'my-app'
end
```

## Running the worker

Include `rest_redis_pub_sub/tasks` in your application:
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
client = RestRedisPubSub::Client.new
client.publish_create(resource, identifier, data)
```
Or a custom one:
```ruby
client = RestRedisPubSub::Client.new('channel')
client.publish_create(resource, identifier, data)
```

It publish to the specified channel the following data in json format:

```json
=> {
  generator: {
    display_name: 'crushpath'
  },
  provider: {
    display_name: 'rest_redis_pub_sub 0.3.1'
  }
  verb: 'create',
  id: 'spot_id',
  actor: {
    object_type: 'user',
    ...
  },
  object: {
    object_type: 'spot',
    ...
  },
  target: {
    object_type: 'etc'
  }
}
```

Available publish events:
```
[
 :add, :call, :change, :comment, :complete, :confirm, :create,
 :dismiss, :email_reply, :evolve, :label, :like, :locate,
 :make_friend, :message, :open, :post, :promote, :publish, :read,
 :receive, :reject, :remove, :request, :request_contact, :send,
 :sign_in, :sign_out, :system, :thank, :unpublish, :update, :view
]
```

## Subscribe

`RestRedisPubSub` will forward all messages received to a class base on the
__generator__, __event__ and __resource__ received:

| Verb      | Object   | Class                   |
|-----------|----------|-------------------------|
| create    | spot     | PublisherSpotCreate     |
| update    | spot     | PublisherSpotUpdate     |

The class must implement a class method `.perform`. If `Resque` is defined it will
enqueue it.

An example class that should be defined in the project to handle the publish message:

```ruby
class Listeners::CrushpathSpotCreate

  def self.perform(id, data)
    ...
  end

end
```
