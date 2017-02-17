# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module ModelHelper
      def get_or_404(cls, key, msg = nil)
        get_or_raise(cls, key, Sinatra::NotFound, msg)
      end

      def get_or_raise(cls, key, ex_cls = KeyError, msg = nil)
        obj = cls[key.to_i]

        if obj.nil?
          msg = "No #{ cls.inspect } with id #{ key }" unless msg
          raise ex_cls, msg
        end

        obj
      end
    end

    helpers ModelHelper
  end
end
