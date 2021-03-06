# frozen_string_literal: true

require "faraday"

require "pacer_api/error"
require "pacer_api/translation"

module PacerApi
  class Session
    include PacerApi::Translation

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

    def get(path)
      res = request(:get, path)
      decode_response(res.body)
    rescue PacerApi::Error => e
      raise ResponseError,
        "Error in GET #{path}: #{e.message}", e.backtrace
    end

    def post(path, doc)
      res = request(:post, path) { |req|
        req.headers["Content-Type"] = "application/json"
        req.body = encode_request(doc)
      }
      decode_response(res.body)
    rescue PacerApi::Error => e
      raise ResponseError,
        "Error in POST #{path} with #{doc.inspect}: #{e.message}",
        e.backtrace
    end

    def delete(path)
      res = request(:delete, path)
      res.status == 204
    end

    def request(verb, path, &blk)
      res = Faraday.public_send(verb, @uri.merge(path)) { |req|
        req.headers["Accept"] = "application/json"
        req.headers["X-NEXT-GEN-CSO"] = @token
        blk.call(req) if block_given?
      }
      update_token! res.headers
      res
    end

  private

    def update_token!(headers)
      new_token = headers["X-NEXT-GEN-CSO"]
      @token = new_token if new_token
    end
  end
end
