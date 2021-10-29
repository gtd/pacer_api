# frozen_string_literal: true

require "ostruct"

require "pacer/case_info"

module Pacer
  PartyInfo = Class.new(OpenStruct) do
    def court_case
      @court_case ||= Pacer::CaseInfo.new(self[:court_case])
    end
  end
end
