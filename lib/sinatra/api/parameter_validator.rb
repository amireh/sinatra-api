module Sinatra::API
  class ParameterValidator
    class << self
      attr_accessor :validators

      def register(api)
        self.validators = {}

        api.on :parameter_parsed do |key, value, definition|
          typename = definition[:type]
          validator = definition[:validator]
          validator ||= ParameterValidator.validators[typename]

          if validator
            # api.logger.debug "Found a validator for #{typename}: #{validator}"

            # Backwards compatibility:
            #
            # validators were plain procs that received the value to validate.
            if validator.respond_to?(:call)
              rc = validator.call(value)
            # Strongly-defined ParameterValidator objects
            elsif validator.respond_to?(:validate)
              rc = validator.validate(value, definition)
            # ?
            else
              raise 'Invalid ParameterValidator, must respond to #call or #validate'
            end

            if rc.is_a?(String)
              api.instance.halt 400, { :"#{key}" => rc }
            end
          end
        end
      end
    end

    attr_accessor :typenames

    def initialize(*typenames)
      out = super()

      self.typenames = typenames.flatten
      self.typenames.each do |typename|
        ParameterValidator.validators[typename.to_s.downcase.to_sym] = self
        # Sinatra::API.logger.debug "Parameter validator defined for type: #{typename}"
      end

      out
    end

    # Validate a given parameter value.
    #
    # @param [Any] value
    #   The parameter value to validate.
    #
    # @param [Hash] options
    #   Custom validator options defined by the user.
    #
    # @return [String] Error message if the parameter value is invalid.
    # @return [Any] Any other value means the parameter is valid.
    def validate(value, options = {})
      raise NotImplementedError
    end
  end
end