# frozen_string_literal: true

require "pacer"

module Pacer
  module Immediate
    class AbstractSearch
      def initialize(session, params)
        @session = session
        @params = params
      end

      def fetch(page = 1)
        build_response(@session.post(endpoint(page), @params))
      end

    private

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
