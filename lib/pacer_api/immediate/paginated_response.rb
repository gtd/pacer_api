# frozen_string_literal: true

module PacerApi
  module Immediate
    PaginatedResponse = Struct.new(:payload) do
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
