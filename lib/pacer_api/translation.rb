# frozen_string_literal: true

require "json"
require "pp" if ENV.key?("DEBUG")

require "pacer_api/error"
require "pacer_api/request_translator"
require "pacer_api/response_translator"

module PacerApi
  module Translation
    def encode_request(obj)
      if ENV.key?("DEBUG")
        puts ">>>>"
        pp obj
      end
      JSON.generate(RequestTranslator.translate(obj))
    rescue JSON::ParserError => e
      raise PacerApi::EncodeError, "#{e.class} #{e.message}", e.backtrace
    end

    def decode_response(body)
      result = ResponseTranslator.translate(JSON.parse(body))
      if ENV.key?("DEBUG")
        puts "<<<<"
        pp result
      end
      result
    rescue JSON::ParserError => e
      raise PacerApi::DecodeError, "#{e.class} #{e.message}", e.backtrace
    end
  end
end
