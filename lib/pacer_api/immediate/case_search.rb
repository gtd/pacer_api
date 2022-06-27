# frozen_string_literal: true

require "pacer_api/immediate/paginated_response"
require "pacer_api/case_info"

module PacerApi
  module Immediate
    class CaseSearch
      PATH = "cases/find?page=%d"

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
        def cases
          @cases ||=
            if payload.key?(:content)
              payload.fetch(:content).map { |h| CaseInfo.new(h) }
            else
              []
            end
        end
      end
    end
  end
end
