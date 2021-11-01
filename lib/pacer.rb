# frozen_string_literal: true

require_relative "pacer/version"

module Pacer
  Error = Class.new(StandardError)
  NotImplementedError = Class.new(StandardError)
end
