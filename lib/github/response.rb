# frozen_string_literal: true

module Github
  class Response
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def success?
      response.success? && query_errors.empty?
    end

    def failure?
      !success?
    end

    def data
      handled_response.fetch('data', [])
    end

    def errors
      return response_errors unless response.success?

      query_errors.map { |e| e.fetch('message', 'Undefined error') }
    end

    def handled_response
      @handled_response ||= JSON.parse(response.body)
    end

    def response_errors
      return [response.return_message] if response.code.zero?

      [response.code, response.status_message, response.return_message].compact.join(' ')
    end

    def query_errors
      @query_errors ||= handled_response.fetch('errors', [])
    end
  end
end
