# frozen_string_literal: true

require_relative "pacer/version"

module Pacer
  Error = Class.new(StandardError)
  AuthenticationError = Class.new(Error)
  NotImplementedError = Class.new(StandardError)
end
