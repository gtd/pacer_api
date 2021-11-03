# frozen_string_literal: true

require "json"
require "pp" if ENV.key?("DEBUG")

require "pacer/request_translator"
require "pacer/response_translator"

module Pacer
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
