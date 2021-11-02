# frozen_string_literal: true

require "ostruct"

module Pacer
  BatchJob = Class.new(OpenStruct) do
    def running?
      status == "RUNNING"
    end

    def completed?
      status == "COMPLETED"
    end
  end
end
