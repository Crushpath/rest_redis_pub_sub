module RestRedisPubSub
  module Configuration
    VERBS = [:add, :call, :change, :comment, :complete, :confirm, :create,
             :dismiss, :email_reply, :evolve, :label, :like, :locate,
             :make_friend, :message, :open, :post, :promote, :publish, :read,
             :receive, :reject, :remove, :request, :request_contact, :response,
             :send, :sign_in, :sign_out, :system, :thank, :unpublish, :update,
             :view]

    def configure(&block)
      block.call(self)
      Client.define_publish_methods
    end

    attr_accessor :subscribe_to, :publish_to, :generator,
                  :listeners_namespace, :redis_instance
    attr_writer   :verbs, :additional_verbs

    def reset!
      @subscribe_to = nil
      @publish_to = nil
      @generator = nil
      @listeners_namespace = nil
      @redis_instance = nil
      @verbs = nil
      @additional_verbs = nil
    end

    def verbs
      (@verbs || RestRedisPubSub::Configuration::VERBS) + additional_verbs
    end

    def additional_verbs
      Array(@additional_verbs)
    end

    def provider
      "rest_redis_pub_sub #{VERSION}"
    end

    def register_signal_handlers
      Signal.trap('TERM') { shutdown }
      Signal.trap('INT')  { shutdown }
      Signal.trap('QUIT') { shutdown }
      Signal.trap('USR1') { shutdown }
      Signal.trap('USR2') { shutdown }

      puts "Registered signals"
    end

    def shutdown
      puts "Exiting..."
      exit
    end
  end

  extend Configuration
end
