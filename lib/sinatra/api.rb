# Copyright (c) 2013 Algol Labs, LLC. <dev@algollabs.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

gem_root = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'json'
require 'sinatra/base'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'sinatra/api/version'
require 'sinatra/api/callbacks'
require 'sinatra/api/helpers'
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
      self.logger = ActiveSupport::Logger.new(STDOUT)

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

  register API
end