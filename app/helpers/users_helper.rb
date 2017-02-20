# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module UsersHelper
      def authenticate!
        if request && request.route_obj && request.route_obj.name.to_s != 'users login'
          login
        end
      end

      def login
        if session.key? 'login_user'
          session['login_user']
        else
          redirect(url(:users, :login))
        end
      end

      def logged_in?
        session['login_user']
      end
    end

    helpers UsersHelper
  end
end
