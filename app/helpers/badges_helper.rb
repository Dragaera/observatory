# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module BadgesHelper
      def badge_image_path(badge)
        "/images/badges/#{ badge.image }"
      end

      def badge_image(badge)
        tag(:img, src: badge_image_path(badge), title: badge.name)
      end
    end

    helpers BadgesHelper
  end
end
