require 'sinatra/api/callbacks'
require 'sinatra/api/resource_aliases'

module Sinatra
  module API
    extend Callbacks
    extend ResourceAliases

    class << self
      attr_accessor :logger
    end

    ResourcePrefix = '::'

    # Parse a JSON construct from a string stream.
    #
    # Override this to use a custom JSON parser, if necessary.
    #
    # @param [String] stream The raw JSON stream.
    #
    # @return [Hash] A Hash of the parsed JSON.
    def parse_json(stream)
      ::JSON.parse(stream)
    end

    def self.registered(app)
      self.logger = Logger.new(STDOUT)

      app.helpers Helpers
      app.before do
        @api = { required: {}, optional: {} }
        @parent_resource = nil

        if api_call?
          request.body.rewind
          body = request.body.read.to_s || ''

          unless body.empty?
            begin
              params.merge!(parse_json(body))
            rescue ::JSON::ParserError => e
              logger.warn e.message
              logger.warn e.backtrace

              halt 400, "Malformed JSON content"
            end
          end
        end
      end

      app.set(:requires) do |*resources|
        condition do
          @required = resources.collect { |r| r.to_s }
          @required.each do |r|
            @parent_resource = __api_locate_resource(r, @parent_resource)
          end
        end
      end
    end
  end
end