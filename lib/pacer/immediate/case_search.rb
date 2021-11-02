# frozen_string_literal: true

require "pacer/immediate/abstract_search"
require "pacer/case_info"

module Pacer
  module Immediate
    class CaseSearch < AbstractSearch
      FRAGMENT = "cases/find?page=%d"

    private

      def build_response(payload)
        Response.new(payload)
      end

      def endpoint(page)
        format(FRAGMENT, page)
      end

      class Response < AbstractResponse
        def cases
          payload.fetch(:content).map { |h| CaseInfo.new(h) }
        end
      end
    end
  end
end
