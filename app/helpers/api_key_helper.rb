# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module ApiKeyHelper
      def api_authenticate!
        token = authorization_token
        halt 403, 'No token supplied' unless token

        api_key = APIKey.where(token: token).first
        halt 403, 'Invalid token supplied' unless api_key
      end

      private
      def authorization_token
        if request.env['HTTP_AUTHORIZATION'] =~ /^Bearer ([a-zA-Z0-9]+)$/
          $1
        end
      end
    end

    helpers ApiKeyHelper
  end
end
