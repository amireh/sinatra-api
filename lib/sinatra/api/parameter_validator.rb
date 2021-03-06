module Sinatra::API
  class ParameterValidator
    attr_accessor :typenames

    def initialize(*typenames)
      self.typenames = typenames.flatten
      super()
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
      attr_accessor :validators, :api

      def install(api)
        self.api = api
        self.api.on :parameter_parsed, &method(:run_validators!)

        install_validators
      end

      private

      def run_validators!(key, hash, definition)
        value = hash[key]
        typename = definition[:type]
        validator = definition[:validator]
        validator = validators[validator] if validator.is_a?(Symbol)
        validator ||= validators[typename]
        definition[:coerce] = true unless definition.has_key?(:coerce)

        if validator
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
            raise "Invalid ParameterValidator #{validator.class}, must respond to #call or #validate"
          end

          if rc.is_a?(String)
            self.api.instance.halt 400, { :"#{key}" => rc }
          end

          # coerce the value, if viable
          if validator.respond_to?(:coerce) && definition[:coerce].present?
            hash[key] = validator.coerce(value, definition)
          end
        end
      end

      # Insantiate an instance of every Sinatra::API::SomethingValidator
      # class defined and register them with the typenames they cover.
      def install_validators
        self.validators = {}

        validator_klasses = self.api.constants.select { |k| k =~ /Validator$/ }
        validator_klasses.each do |klass_id|
          klass = self.api.const_get(klass_id)
          validator = klass.new

          unless validator.respond_to?(:validate)
            raise "Invalid ParameterValidator #{klass_id}, must respond to #validate"
          end

          validator.typenames.each do |typename|
            api.logger.debug "Validator defined: #{typename}"
            validators[typename.to_s.downcase.to_sym] = validator
          end
        end
      end
    end
  end
end