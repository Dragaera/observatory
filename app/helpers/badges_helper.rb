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

      def skill_tier_badge_image_path(badge)
        "/images/skill_tier_badges/#{ badge.image }"
      end

      def skill_tier_badge_image(badge, height: nil, width: nil, cls: nil, narrow: false)
        shadowed_class = narrow ? 'shadowed-narrow' : 'shadowed'
        attrs = {
          src: skill_tier_badge_image_path(badge),
          title: badge.name,
          class: shadowed_class
        }
        attrs[:height] = height if height
        attrs[:width]  = width if width
        attrs[:class]  = "#{ shadowed_class } #{ cls }" if cls

        tag(:img, **attrs)
      end
    end

    helpers BadgesHelper
  end
end
