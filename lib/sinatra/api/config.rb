module Sinatra::API
  class Config
    attr_accessor :with_errors
    attr_accessor :with_parameter_validations

    Defaults = {
      with_errors: true,
      with_parameter_validations: true
    }

    def initialize(options = {})
      api = Sinatra::API

      options = {}.merge(Config::Defaults).merge(options)
      options.each_pair do |key, setting|
        unless self.respond_to?(key)
          api.logger.warn "Unknown option #{key} => #{setting}"
          next
        end

        self[key] = setting if changed?(key, setting)
      end

      super()
    end

    def [](key)
      self.send key rescue nil
    end

    def []=(key, value)
      self.send("#{key}=", value)
      Sinatra::API.trigger "#{key}_setting", value
    end

    private

    def changed?(key, value)
      self[key] != value
    end
  end
end
