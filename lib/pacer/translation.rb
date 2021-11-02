# frozen_string_literal: true

require "json"

require "pacer/request_translator"
require "pacer/response_translator"

module Pacer
  module Translation
    def encode_request(obj)
      JSON.generate(RequestTranslator.translate(obj))
    end

    def decode_response(body)
      ResponseTranslator.translate(JSON.parse(body))
    end
  end
end
