# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module BadgesHelper
      def badge_image_path(badge)
        "/images/badges/#{ badge.image }"
      end
      # def simple_helper_method
      # ...
      # end
    end

    helpers BadgesHelper
  end
end
