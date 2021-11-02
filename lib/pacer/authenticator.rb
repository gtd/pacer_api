# frozen_string_literal: true

require "faraday"
require "json"

require "pacer"
require "pacer/session"

module Pacer
  class Authenticator
    HOSTS = {
      production: "pacer.login.uscourts.gov",
      qa: "qa-login.uscourts.gov"
    }.freeze

    PATH = "/services/cso-auth"

    def initialize(
      login_id, password, client_code: nil, environment: :production
    )
      @login_id = login_id
      @password = password
      @client_code = client_code
      @environment = environment
      @uri = URI::HTTPS.build(
        host: HOSTS.fetch(environment),
        path: PATH
      )
    end

    def authenticate
      res = Faraday.post(@uri) { |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Accept"] = "application/json"
        req.body = build_request_body
      }
      parse_response(res.body)
    end

  private

    def build_request_body
      params = {
        "loginId" => @login_id,
        "password" => @password,
        "redactFlag" => "1"
      }
      params["clientCode"] = @client_code if @client_code
      JSON.generate(params)
    end

    def parse_response(body)
      data = JSON.parse(body)
      if data.fetch("loginResult") != "0"
        raise AuthenticationError, data.fetch("errorDescription")
      end

      Session.new(data.fetch("nextGenCSO"), environment: @environment)
    end
  end
end
