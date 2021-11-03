# frozen_string_literal: true

require "pacer/immediate/paginated_response"
require "pacer/case_info"

module Pacer
  module Immediate
    class CaseSearch
      PATH = "cases/find?page=%d"

      def initialize(session, params)
        @session = session
        @params = params
      end

      def fetch(page = 1)
        path = format(PATH, page)
        payload = @session.post(path, @params)
        Page.new(payload)
      end

      class Page < PaginatedResponse
        def cases
          payload.fetch(:content).map { |h| CaseInfo.new(h) }
        end
      end
    end
  end
end
