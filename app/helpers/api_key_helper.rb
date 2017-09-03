# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module ApiKeyHelper
      def api_authenticate!
        token = authorization_token
        halt 403, { error: 'No token supplied' }.to_json unless token

        api_key = APIKey.authenticate(token)
        halt 403, { error: 'Invalid token supplied' }.to_json unless api_key
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
