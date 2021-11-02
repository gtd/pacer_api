# frozen_string_literal: true

require "faraday"

require "pacer/translation"

module Pacer
  class Session
    include Pacer::Api::Translation

    HOSTS = {
      production: "pcl.uscourts.gov",
      qa: "qa-pcl.uscourts.gov"
    }.freeze

    BASE_PATH = "/pcl-public-api/rest/"

    def initialize(token, environment: :production)
      @token = token
      @uri = URI::HTTPS.build(
        host: HOSTS.fetch(environment),
        path: BASE_PATH
      )
    end

    def post(path, doc)
      res = Faraday.post(@uri.merge(path)) { |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Accept"] = "application/json"
        req.headers["X-NEXT-GEN-CSO"] = @token
        req.body = encode_request(doc)
      }
      update_token! res.headers
      decode_response(res.body)
    end

  private

    def update_token!(headers)
      new_token = headers["X-NEXT-GEN-CSO"]
      @token = new_token if new_token
    end
  end
end
