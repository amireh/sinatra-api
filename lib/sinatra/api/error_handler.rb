module Sinatra::API
  module ErrorHandler
    def format_api_error(message)
      field_errors = {}

      message = case
      when message.is_a?(String)
        [ message ]
      when message.is_a?(Array)
        message
      when message.is_a?(Hash)
        field_errors = message
        message.collect { |k,v| v }
      when message.is_a?(DataMapper::Validations::ValidationErrors)
        field_errors = message.to_hash
        message.to_hash.collect { |k,v| v }.flatten
      else
        [ "unexpected response: #{message.class} -> #{message}" ]
      end

      [ field_errors, message ]
    end

    def handle_api_error(message = response.body)
      # Support for CORS pre-flight requests
      if request.request_method == 'OPTIONS'
        content_type :text
        halt response.status
      end

      status response.status
      content_type :json

      field_errors, message = *format_api_error(message)

      {
        code: response.status,
        status: 'error',
        messages: message,
        field_errors: field_errors
      }.to_json
    end

    def self.included(base)
      base.error 400 do
        handle_api_error if api_call?
      end

      base.error 404 do
        handle_api_error if api_call?
      end
    end
  end
end