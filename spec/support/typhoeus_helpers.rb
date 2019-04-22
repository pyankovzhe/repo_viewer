# frozen_string_literal: true

module TyphoeusHelpers
  def stub_typhoeus_request(endpoint, payload, http_status)
    options = {
      code: http_status,
      body: payload.to_json,
      return_code: http_status,
    }

    response = Typhoeus::Response.new(options)
    Typhoeus.stub(endpoint).and_return(response)
  end
end
