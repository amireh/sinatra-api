module Sinatra::API
  class IntegerValidator < ParameterValidator
    def initialize
      super(:integer)
    end

    def validate(value, options)
      Integer(value)
    rescue
      "Not a valid integer."
    end

    def coerce(value, options)
      Integer(value)
    end
  end
end