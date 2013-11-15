module Rack
  module Test
    class APIResponse
      attr_reader :rr, :body, :status, :messages, :http_rc

      def initialize(rack_response)
        @rr       = rack_response
        @http_rc  = @rr.status
        begin;
          @body = JSON.parse(@rr.body.empty? ? '{}' : @rr.body)
          @body = @body.with_indifferent_access
        rescue JSON::ParserError => e
          raise "Invalid API response;" +
            "body could not be parsed as JSON:\n#{@rr.body}\nException: #{e.message}"
        end

        @status   = :success
        @messages = []

        unless blank?
          if @body.is_a?(Hash)
            @status   = @body["status"].to_sym  if @body.has_key?("status")
            @messages = @body["messages"]       if @body.has_key?("messages")
          elsif @body.is_a?(Array)
            @messages = @body
          else
            @messages = @body
          end
        end
      end

      def blank?
        @body.empty?
      end

      def succeeded?
        !blank? && @status == :success
      end

      def failed?
        !blank? && @status == :error
      end
    end # APIResponse
  end # Test
end # Rack
