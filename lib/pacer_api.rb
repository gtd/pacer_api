# frozen_string_literal: true

require_relative "pacer_api/version"

module PacerApi
  Error = Class.new(StandardError)
  AuthenticationError = Class.new(Error)
  NotImplementedError = Class.new(StandardError)
end
