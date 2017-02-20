# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module FormatHelperHelper
      SECONDS_PER_MINUTE = 60
      SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
      SECONDS_PER_DAY = SECONDS_PER_HOUR * 24

      def pp_timespan(seconds)
        if seconds >= SECONDS_PER_DAY
          days = seconds / SECONDS_PER_DAY
          seconds -= days * SECONDS_PER_DAY
        else
          days = 0
        end

        if seconds >= SECONDS_PER_HOUR
          hours = seconds / SECONDS_PER_HOUR
          seconds -= hours * SECONDS_PER_HOUR
        else
          hours = 0
        end

        if seconds >= SECONDS_PER_MINUTE
          minutes = seconds / SECONDS_PER_MINUTE
          seconds -= minutes * SECONDS_PER_MINUTE
        else
          minutes = 0
        end

        out = []
        out << "#{ days }d" if days > 0
        out << "#{ hours }h" if hours > 0
        out << "#{ minutes }m" if minutes > 0
        out << "#{ seconds }s" if seconds > 0 || (seconds == 0 && minutes == 0 && hours == 0 && days == 0)

        out.join(' ')
      end

      def pp_separator(number, sep = "'")
        number.to_s.reverse.gsub(/\d\d\d(?=\d)/) { |s| "#{ s }#{ sep }" }.reverse
      end

      def pp_percentage(part, full, accuracy = 1)
        percentage = (part * 100.0 / full).round(accuracy)

        "#{ percentage }%"
      end

      def to_bool(input)
        if ['1', 1, 'true', 'y', 'yes'].include? input
          true
        elsif ['0', 0, 'false', 'n', 'no'].include? input
          false
        else
          raise ArgumentError, "#{ input.inspect } could not be interpreted as boolean"
        end
      end
    end

    helpers FormatHelperHelper
  end
end
