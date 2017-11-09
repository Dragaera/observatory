# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module FormatHelperHelper
      SECONDS_PER_MINUTE = 60
      SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
      SECONDS_PER_DAY = SECONDS_PER_HOUR * 24

      def to_bool(input)
        if ['1', 1, 'true', 'y', 'yes'].include? input
          true
        elsif ['0', 0, 'false', 'n', 'no'].include? input
          false
        else
          raise ArgumentError, "#{ input.inspect } could not be interpreted as boolean"
        end
      end

      def pp_form_errors(form_errors)
        form_errors.map do |attr, errors|
          "#{ attr.capitalize }: #{ errors.map(&:capitalize).join(', ') }"
        end
      end

      def pp_date(date)
        date.strftime(Config::Localization::DATE_FORMAT)
      end

      def pp_datetime(datetime)
        datetime.strftime(Config::Localization::DATETIME_FORMAT)
      end
    end

    helpers FormatHelperHelper
  end
end
