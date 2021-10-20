# frozen_string_literal: true

require "json"
require "faraday"

module Pacer
  module Api
    class Authenticator
      DOMAINS = {
        production: "pacer.login.uscourts.gov",
        qa: "qa-login.uscourts.gov"
      }.freeze
      URL = "https://%s/services/cso-auth"

      def initialize(
        login_id, password, client_code: nil, environment: :production
      )
        @login_id = login_id
        @password = password
        @client_code = client_code
        @environment = environment
      end

      def authenticate
        res = Faraday.post(endpoint) { |req|
          req.headers["Content-Type"] = "application/json"
          req.headers["Accept"] = "application/json"
          req.body = build_request_body
        }
        parse_response(res.body)
      end

    private

      def endpoint
        format(URL, DOMAINS.fetch(@environment))
      end

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
        Response.new(
          data.fetch("nextGenCSO", nil),
          data.fetch("loginResult"),
          data.fetch("errorDescription", nil)
        )
      end

      Response = Struct.new(:next_gen_cso, :login_result, :error_description) do
        alias_method :token, :next_gen_cso
        def success?
          login_result == "0"
        end
      end
    end
  end
end
