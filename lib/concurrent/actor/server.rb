module Concurrent
  module Actor
    class Server

      DEFAULT_HOST = 'localhost'
      DEFAULT_PORT = 8787

      attr_accessor :actor_pool

      def initialize(host = DEFAULT_HOST, port = DEFAULT_PORT)
        @host       = host
        @port       = port
        @actor_pool = {}
      end

      def running?
        @drb_server.alive?
      end

      def pool(name, actor, cons_arguments)
        @actor_pool[name] = new_actor_pool(actor, name, cons_arguments)
      end

      def tell(name, *args)
        raise ArgumentError.new("no registration for #{name}") unless @actor_pool[name]
        return @actor_pool[name].tell(*args)
      end

      private

      def server_uri
        @server_uri ||= "druby://#{@host}:#{@port}"
      end

      def start_drb_server
        @drb_server = DRb.start_service(server_uri, self)
      end

      def new_actor_pool(actor, name, cons_arguments)
        actor.spawn(name, cons_arguments)
      end
    end
  end
end
