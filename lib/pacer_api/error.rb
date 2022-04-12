# frozen_string_literal: true

module PacerApi
  Error = Class.new(StandardError)
  AuthenticationError = Class.new(Error)
  NotImplementedError = Class.new(StandardError)
  ResponseError = Class.new(Error)
  EncodeError = Class.new(Error)
  DecodeError = Class.new(Error)
end
