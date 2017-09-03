# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module ApiKeyHelper
      def api_authenticate!
        p request.env
        puts "HELLO"
      end
    end

    helpers ApiKeyHelper
  end
end
