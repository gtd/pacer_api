# frozen_string_literal: true

require "ostruct"

require "pacer_api/case_info"

module PacerApi
  PartyInfo = Class.new(OpenStruct) do
    def court_case
      @court_case ||= PacerApi::CaseInfo.new(self[:court_case])
    end
  end
end
