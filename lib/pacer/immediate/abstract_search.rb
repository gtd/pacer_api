# frozen_string_literal: true

require "faraday"
require "json"

require "pacer"
require "pacer/translation"

module Pacer
  module Immediate
    class AbstractSearch
      include Pacer::Api::Translation

      DOMAINS = {
        production: "pcl.uscourts.gov",
        qa: "qa-pcl.uscourts.gov"
      }.freeze

      def initialize(token, params, client_code: nil, environment: :production)
        @token = token
        @params = params
        @client_code = client_code
        @environment = environment
      end

      def run(page = 1)
        request(@params, page)
      end

    private

      def request(params, page)
        res = Faraday.post(endpoint(page)) { |req|
          req.headers["Content-Type"] = "application/json"
          req.headers["Accept"] = "application/json"
          req.headers["X-NEXT-GEN-CSO"] = @token
          req.headers["X-CLIENT-CODE"] = @client_code if @client_code
          req.body = encode_request(params)
        }
        build_response(decode_response(res.body))
      end

      def build_response(_payload)
        raise NotImplementedError
      end

      def endpoint(_page)
        raise NotImplementedError
      end

      AbstractResponse = Struct.new(:payload) do
        def page
          page_info(:number)
        end

        def total_pages
          page_info(:total_pages)
        end

        def total_elements
          page_info(:total_elements)
        end

        def last?
          page_info(:last)
        end

      private

        def page_info(key)
          payload.fetch(:page_info).fetch(key)
        end
      end
    end
  end
end
