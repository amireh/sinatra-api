module Sinatra::API
  class ParameterValidator
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

    class << self
      attr_accessor :validators

      def install(api)
        install_validators(api)

        api.on :parameter_parsed do |key, value, definition|
          typename = definition[:type]
          validator = definition[:validator]

          if typename && !validator
            validator = ParameterValidator.validators[typename]
          end

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

      private

      def install_validators(api)
        base = self
        self.validators = {}

        validator_klasses = api.constants.select { |k| k =~ /Validator$/ }
        validator_klasses.each do |klass_id|
          klass = api.const_get(klass_id)
          validator = klass.new

          unless validator.respond_to?(:validate)
            raise "Invalid ParameterValidator #{klass_id}, must respond to #validate"
          end
        end
      end
    end
  end
end