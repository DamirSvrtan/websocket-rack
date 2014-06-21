module Rack
  module WebSocket
    module Handler
      class Base
                
        autoload :Connection, "#{ROOT_PATH}/websocket/handler/base/connection"

        def on_open
          set_parent_instance_variables
          @parent.on_open(@env)
        end # Fired when a client is connected.

        def on_message(msg)
          set_parent_instance_variables
          @parent.on_message(@env, msg)
        end # Fired when a message from a client is received.

        def on_close
          set_parent_instance_variables
          @parent.on_close(@env)
        end # Fired when a client is disconnected.

        def on_error(error)
          set_parent_instance_variables
          @parent.on_error(@env, error)
        end # Fired when error occurs.

        # Set application as parent and forward options
        def initialize(parent, options = {})
          @parent = parent
          @options = options[:backend] || {}
        end

        def set_parent_instance_variables
          set_env_instance_variable
          set_session_instance_variable
        end

        def set_env_instance_variable
          @parent.instance_variable_set("@env", @env)
        end

        def set_session_instance_variable
          session = Noodles.use_memached_as_session_storage ? Noodles::MemcachedSession.new(@env) : @env['rack.session']
          @parent.instance_variable_set("@session", session)
        end

        # Implemented in subclass
        def call(env)
          raise 'Not implemented'
        end

        # Implemented in subclass
        def send_data(data)
          raise 'Not implemented'
        end

        # Implemented in subclass
        def close_websocket
          raise 'Not implemented'
        end

        protected

        # Standard async response
        def async_response
          [-1, {}, []]
        end

        # Standard 400 response
        def failure_response
          [ 400, {'Content-Type' => 'text/plain'}, [ 'Bad request' ] ]
        end

      end
    end
  end
end