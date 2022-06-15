# frozen_string_literal: true

require "pacer_api/immediate/paginated_response"
require "pacer_api/party_info"

module PacerApi
  module Immediate
    class PartySearch
      PATH = "parties/find?page=%d"

      def initialize(session, params)
        @session = session
        @params = params
      end

      def fetch(page = 0)
        path = format(PATH, page)
        payload = @session.post(path, @params)
        Page.new(payload)
      end

      class Page < PaginatedResponse
        def parties
          payload.fetch(:content).map { |h| PartyInfo.new(h) }
        end
      end
    end
  end
end
