# frozen_string_literal: true

require "pacer/session"

RSpec.describe Pacer::Session do
  subject(:session) { described_class.new(token, environment: :qa) }

  let(:token) { "TOKEN123" }

  before do
    stub_request(:any, %r{\Ahttps://qa-pcl.uscourts.gov/})
      .to_return(body: "{}")
  end

  describe "post" do
    it "constructs a URL based on environment and path fragment" do
      session.post("fragment", {})
      expect(WebMock)
        .to have_requested(
          :post, "https://qa-pcl.uscourts.gov/pcl-public-api/rest/fragment"
        )
    end

    it "translates and JSON encodes request document" do
      session.post("path", { a_key: "value" })
      expect(WebMock)
        .to have_requested(:post, /.*/)
        .with(body: JSON.generate("aKey" => "value"))
    end

    it "JSON decodes and translates response body" do
      stub_request(:any, %r{\Ahttps://qa-pcl.uscourts.gov/})
        .to_return(body: '{"aKey": "value"}')
      response = session.post("path", {})
      expect(response).to eq(a_key: "value")
    end

    it "sends required headers" do
      session.post("path", {})
      expect(WebMock)
        .to have_requested(:post, /.*/)
        .with(headers: {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "X-NEXT-GEN-CSO" => token
        })
    end

    it "reuses the token if not expired" do
      3.times do
        session.post("path", {})
      end
      expect(WebMock)
        .to have_requested(:post, /.*/)
        .with(headers: { "X-NEXT-GEN-CSO" => token })
        .times(3)
    end

    it "picks up a new token" do
      new_token = "NEW345"
      stub_request(:any, %r{\Ahttps://qa-pcl.uscourts.gov/})
        .to_return(body: "{}", headers: { "X-NEXT-GEN-CSO": new_token }).then
        .to_return(body: "{}")
      session.post("first", {})
      session.post("second", {})
      expect(WebMock)
        .to have_requested(
          :post, "https://qa-pcl.uscourts.gov/pcl-public-api/rest/second"
        )
        .with(headers: { "X-NEXT-GEN-CSO" => new_token })
    end
  end
end
