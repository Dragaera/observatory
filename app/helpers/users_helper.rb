# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module UsersHelper
      def authenticate!
        # Don't enforce authentication on login page. ;)
        if request && request.route_obj && request.route_obj.name.to_s != 'users login'
          current_user || redirect((url(:users, :login)))
        end
      end

      def current_user
        return nil unless session.key? 'login_user_id'
        id = session['login_user_id'].to_i
        User[id]
      end

      def logged_in?
        !!current_user
      end
    end

    helpers UsersHelper
  end
end
