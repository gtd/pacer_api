# frozen_string_literal: true

require "active_support/inflector"
require "faraday"
require "json"
require "ostruct"

require "pacer/api/translation"

module Pacer
  module Api
    class CaseSearch
      include Pacer::Api::Translation

      DOMAINS = {
        production: "pcl.uscourts.gov",
        qa: "qa-pcl.uscourts.gov"
      }.freeze
      URL = "https://%s/pcl-public-api/rest/cases/find?page=%d"

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
        Response.new(decode_response(res.body))
      end

      def endpoint(page)
        format(URL, DOMAINS.fetch(@environment), page)
      end

      Response = Struct.new(:payload) do
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

        def cases
          payload.fetch(:content).map { |h| CaseInfo.new(h) }
        end

      private

        def page_info(key)
          payload.fetch(:page_info).fetch(key)
        end
      end

      CaseInfo = Class.new(OpenStruct)
    end
  end
end
