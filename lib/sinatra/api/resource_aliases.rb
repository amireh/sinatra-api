module Sinatra
  module API
    module ResourceAliases
      attr_accessor :resource_aliases

      def self.extended(base)
        base.resource_aliases = {}
        base.on :resource_located, &method(:export_alias)
      end

      def alias_resource(original, resource_alias)
        key, resource_alias = original.to_sym, resource_alias.to_s

        self.resource_aliases[key] ||= []

        return if self.resource_aliases[key].include?(resource_alias)
        return if key.to_s == resource_alias

        self.resource_aliases[key] << resource_alias
        logger.debug "API resource #{original} is now aliased as #{resource_alias}"
      end

      def aliases_for(resource)
        self.resource_aliases[resource.to_sym] || []
      end

      def reset_aliases!
        self.resource_aliases = {}
      end

      private

      def self.export_alias(resource, name)
        base = Sinatra::API
        base.aliases_for(name).each do |resource_alias|
          base.instance.instance_variable_set("@#{resource_alias}", resource)
        end
      end
    end
  end
end