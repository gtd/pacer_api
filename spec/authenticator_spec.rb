# frozen_string_literal: true

require "pacer/authenticator"

RSpec.describe Pacer::Authenticator do
  subject(:authenticator) {
    described_class.new("kodos2024", "Passw0rd", environment: :qa)
  }

  let(:response_body) { '{"nextGenCSO":"a","loginResult":"0"}' }
  let(:response_headers) { {} }

  before do
    stub_request(:post, %r{\Ahttps://qa-login.uscourts.gov/})
      .to_return(body: response_body, headers: response_headers)
  end

  describe "authentication" do
    it "sends JSON request headers" do
      authenticator.authenticate

      expect(WebMock)
        .to have_requested(:post, /.*/)
        .with(headers: {
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        })
    end

    it "posts the required body" do
      authenticator.authenticate

      expect(WebMock)
        .to have_requested(:post, /.*/)
        .with { |req|
          JSON.parse(req.body) == {
            "loginId" => "kodos2024",
            "password" => "Passw0rd",
            "redactFlag" => "1"
          }
        }
    end

    context "when unsuccessful" do
      let(:response_body) {
        '{"loginResult":"1","errorDescription":"Login Failed"}'
      }

      it "raises an exception with the error description" do
        expect { authenticator.authenticate }
          .to raise_exception(Pacer::AuthenticationError)
          .with_message("Login Failed")
      end
    end

    context "when successful" do
      let(:response_body) { '{"nextGenCSO":"CSOTOKEN","loginResult":"0"}' }

      it "returns a session object" do
        expect(authenticator.authenticate).to be_kind_of(Pacer::Session)
      end

      it "initializes the session object with the token and environment" do
        allow(Pacer::Session).to receive(:new)

        authenticator.authenticate

        expect(Pacer::Session)
          .to have_received(:new)
          .with("CSOTOKEN", environment: :qa)
      end
    end
  end
end
