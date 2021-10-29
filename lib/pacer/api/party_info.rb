# frozen_string_literal: true

require "ostruct"

require "pacer/api/case_info"

module Pacer
  module Api
    PartyInfo = Class.new(OpenStruct) do
      def court_case
        @court_case ||= CaseInfo.new(self[:court_case])
      end
    end
  end
end
