# frozen_string_literal: true

require "pacer/immediate/abstract_search"
require "pacer/case_info"
require "pacer/party_info"

module Pacer
  module Immediate
    class PartySearch < AbstractSearch
      URL = "https://%s/pcl-public-api/rest/parties/find?page=%d"

    private

      def build_response(payload)
        Response.new(payload)
      end

      def endpoint(page)
        format(URL, DOMAINS.fetch(@environment), page)
      end

      class Response < AbstractResponse
        def parties
          payload.fetch(:content).map { |h| PartyInfo.new(h) }
        end
      end
    end
  end
end
