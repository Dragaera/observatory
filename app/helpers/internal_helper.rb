# Helper methods defined here can be accessed in any controller or view in the application

require 'socket'

module Observatory
  class App
    module InternalHelper
      def check_db_connectivity
        begin
          return false unless Sequel::Model.db.test_connection
          return false unless Sequel::Model.db.valid_connection? Sequel::Model.db
        rescue Sequel::Error => e
          # TODO: Log
          return false
        end
        return true
      end

      def check_service_connectivity(host, port, timeout: 1)
        begin
          Socket.tcp(host, port, connect_timeout: timeout) {}
          true
        rescue Errno::ETIMEDOUT, SocketError
          false
        end
      end
    end

    helpers InternalHelper
  end
end
