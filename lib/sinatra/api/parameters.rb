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
#

module Sinatra::API
  # API for defining parameters an endpoint requires or accepts, their types,
  # and optional validators.
  #
  # TODO: accept nested parameters
  module Parameters
    attr_accessor :api_parameter_records

    # Define the required API arguments map. Any item defined
    # not found in the supplied parameters of the API call will
    # result in a 400 RC with a proper message marking the missing
    # field.
    #
    # The map is a Hash of parameter keys and optional validator blocks.
    #
    # @example A map of required API call arguments
    #   api_required!({ title: nil, user_id: nil })
    #
    # Each entry can be optionally mapped to a validation proc that will
    # be invoked *if* the field was supplied. The proc will be passed
    # the value of the field.
    #
    # If the value is invalid and you need to suspend the request, you
    # must return a String object with an appropriate error message.
    #
    # @example Rejecting a title if it's rude
    #   api_required!({
    #     :title => lambda { |t| return "Don't be rude" if t && t =~ /rude/ }
    #   })
    #
    # @note
    #   The supplied value passed to validation blocks is not pre-processed,
    #   so you must make sure that you check for nils or bad values in validator blocks!
    def api_required!(args, h = params)
      args = api_parameters_to_hash(args) if args.is_a?(Array)

      args.each_pair do |name, cnd|
        if cnd.is_a?(Hash)
          api_required!(cnd, h[name])
          next
        end

        parse_api_parameter(name, cnd, :required, h)
      end
    end

    # Same as #api_required! except that fields defined in this map
    # are optional and will be used only if they're supplied.
    #
    # @see #api_required!
    def api_optional!(args, h = params)
      args.each_pair { |name, cnd|
        if cnd.is_a?(Hash)
          api_optional!(cnd, h[name])
          next
        end

        parse_api_parameter(name, cnd, :optional, h)
      }
    end

    def api_parameter!(id, options = {}, hash = params)
      parameter_type = options[:required] ? :required : :optional
      parameter_validator = options[:validator]

      parse_api_parameter(id, parameter_validator, parameter_type, hash, options)
    end

    # Consumes supplied parameters with the given keys from the API
    # parameter map, and yields the consumed values for processing by
    # the supplied block (if any).
    #
    # This is useful when a certain parameter does not correspond to a model
    # attribute and needs to be renamed, or is used only in a validation context.
    #
    # Use #api_transform! if you only need to convert the value or process it.
    def api_consume!(keys)
      out  = nil

      keys = [ keys ] unless keys.is_a?(Array)
      keys.each do |k|
        if val = @api[:required].delete(k.to_sym)
          out = val
          out = yield(val) if block_given?
        end

        if val = @api[:optional].delete(k.to_sym)
          out = val
          out = yield(val) if block_given?
        end
      end

      out
    end

    # Transform the value for the given parameter in-place. Useful for
    # post-processing or converting raw values.
    #
    # @param [String, Symbol] key
    #   The key of the parameter defined earlier.
    #
    # @param [#call] handler
    #   A callable construct that will receive the original value and should
    #   return the transformed one.
    def api_transform!(key, &handler)
      key = key.to_sym

      if val = @api[:required][key]
        @api[:required][key] = yield(val) if block_given?
      end

      if val = @api[:optional][key]
        @api[:optional][key] = yield(val) if block_given?
      end
    end

    # Is the specified *optional* parameter supplied by the request?
    def api_has_param?(key)
      @api[:optional].has_key?(key)
    end
    alias_method :has_api_parameter?, :api_has_param?

    # Get the value of the given API parameter, if any.
    def api_param(key)
      @api[:optional][key.to_sym] || @api[:required][key.to_sym]
    end
    alias_method :api_parameter, :api_param

    # Returns a Hash of the *supplied* request parameters. Rejects
    # any parameter that was not defined in the REQUIRED or OPTIONAL
    # maps (or was consumed).
    #
    # @param [Hash] q
    #   A Hash of attributes to merge with the parameters, useful for defining
    #   defaults.
    def api_params(q = {})
      @api[:optional].deep_merge(@api[:required]).deep_merge(q)
    end

    def api_clear!()
      @api = { required: {}, optional: {} }
    end
    alias_method :api_reset!, :api_clear!

    private

    def parse_api_parameter(name, cnd, type, h = params, options = {})
      # cnd ||= lambda { |*_| true }
      name = name.to_s

      options[:validator] ||= cnd

      unless [ :required, :optional ].include?(type)
        raise ArgumentError, 'API Argument type must be either :required or :optional'
      end

      if !h.has_key?(name)
        if type == :required
          halt 400, "Missing required parameter :#{name}"
        end
      else
        Sinatra::API.trigger :parameter_parsed, name, h[name], options

        # if cnd.respond_to?(:call)
        #   errmsg = cnd.call(h[name])
        #   halt 400, { :"#{name}" => errmsg } if errmsg && errmsg.is_a?(String)
        # end

        @api[type][name.to_sym] = h[name]
      end
    end

    def api_parameters_to_hash(args)
      converted = {}
      args.each { |name| converted[name] = nil }
      converted
    end

    def self.included(app)
      Sinatra::API.on :request do |request_scope|
        request_scope.instance_eval &:api_reset!
      end
    end
  end
end