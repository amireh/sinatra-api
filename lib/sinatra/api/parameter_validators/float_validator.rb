module Sinatra::API
  class FloatValidator < ParameterValidator
    def initialize
      super(:float)
    end

    def validate(value, options)
      Float(value)
    rescue
      "Not a valid float."
    end

    def coerce(value, options)
      Float(value)
    end
  end
end