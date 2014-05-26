module RestRedisPubSub
  module Configuration
    VERBS = [:add, :call, :change, :comment, :complete, :confirm, :create,
             :dismiss, :email_reply, :evolve, :label, :like, :locate,
             :make_friend, :message, :open, :post, :promote, :publish, :read,
             :receive, :reject, :remove, :request, :request_contact, :send,
             :sign_in, :sign_out, :system, :thank, :unpublish, :update, :view]

    def configure(&block)
      block.call(self)
      Client.define_publish_methods
    end

    attr_accessor :subscribe_to, :publish_to, :generator,
                  :listeners_namespace, :redis_instance
    attr_reader   :provider
    attr_writer   :verbs

    def reset!
      @subscribe_to = nil
      @publish_to = nil
      @generator = nil
      @listeners_namespace = nil
      @redis_instance = nil
      @verbs = nil
      @provider = "rest_redis_pub_sub #{VERSION}"
    end

    def verbs
      @verbs || RestRedisPubSub::Configuration::VERBS
    end
  end

  extend Configuration
end
