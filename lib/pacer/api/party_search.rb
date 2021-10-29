# frozen_string_literal: true

require "pacer/api/immediate_search"
require "pacer/api/case_info"
require "pacer/api/party_info"

module Pacer
  module Api
    class PartySearch < ImmediateSearch
      URL = "https://%s/pcl-public-api/rest/parties/find?page=%d"

    private

      def build_response(payload)
        Response.new(payload)
      end

      def endpoint(page)
        format(URL, DOMAINS.fetch(@environment), page)
      end

      class Response < ImmediateSearch::AbstractResponse
        def parties
          payload.fetch(:content).map { |h| PartyInfo.new(h) }
        end
      end
    end
  end
end
