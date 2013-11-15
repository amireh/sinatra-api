module Sinatra::API
  class StringValidator < ParameterValidator
    def initialize
      super(:string, String)
    end

    def validate(value, options)
      unless value.is_a?(String)
        return "Expected value to be of type String, got #{value.class.name}"
      end

      if options[:format] && !value =~ options[:format]
        return "Invalid format."
      end
    end
  end
end