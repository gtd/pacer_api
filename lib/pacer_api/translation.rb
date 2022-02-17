# frozen_string_literal: true

require "json"
require "pp" if ENV.key?("DEBUG")

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
    end

    def decode_response(body)
      ResponseTranslator.translate(JSON.parse(body)).tap { |obj|
        if ENV.key?("DEBUG")
          puts "<<<<"
          pp obj
        end
      }
    end
  end
end
