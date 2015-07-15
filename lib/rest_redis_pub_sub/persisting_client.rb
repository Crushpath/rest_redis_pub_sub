require 'json'
require 'mongoid'

module RestRedisPubSub
  class PersistingClient < RestRedisPubSub::Client

    protected
    def publish(options={})
      super(options)

    end

    def publish_to_mongo
      begin
        setup_db
        publish_activity
        done_with_db
      rescue => ex
        puts "Error #{ex} publishing #{json_object.inspect}. Backtrace #{ex.backtrace.join("\n")}"
      end
    end

    def check_db
      if db_name && Mongoid.sessions[db_name].nil?
        raise "No mongo session with name #{db_name}"
      end
    end

    def publish_activity
      activity = ActivityStreams::Activity.new(json_object)
      activity.save
    end

    def setup_db
      check_db
      Mongoid.override_database(db_name) if db_name
    end

    def done_with_db
      Mongoid.override_database(nil) if db_name
    end

    def db_name
      RestRedisPubSub.mongoid_session_name.presence
    end

  end
end