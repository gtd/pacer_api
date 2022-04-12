# frozen_string_literal: true

require "pacer_api/session"

RSpec.describe PacerApi::Session do
  subject(:session) { described_class.new(token, environment: :qa) }

  let(:token) { "TOKEN123" }

  before do
    stub_request(:any, %r{\Ahttps://qa-pcl.uscourts.gov/})
      .to_return(body: "{}")
  end

  describe "session token" do
    it "reuses the token if not expired" do
      3.times do
        session.get("path")
      end
      expect(WebMock)
        .to have_requested(:get, /.*/)
        .with(headers: { "X-NEXT-GEN-CSO" => token })
        .times(3)
    end

    it "picks up a new token" do
      new_token = "NEW345"
      stub_request(:any, %r{\Ahttps://qa-pcl.uscourts.gov/})
        .to_return(body: "{}", headers: { "X-NEXT-GEN-CSO": new_token }).then
        .to_return(body: "{}")
      session.get("first")
      session.get("second")
      expect(WebMock)
        .to have_requested(
          :get, "https://qa-pcl.uscourts.gov/pcl-public-api/rest/second"
        )
        .with(headers: { "X-NEXT-GEN-CSO" => new_token })
    end
  end

  describe "get" do
    it "constructs request URL and headers" do
      session.get("fragment")
      expect(WebMock)
        .to have_requested(
          :get, "https://qa-pcl.uscourts.gov/pcl-public-api/rest/fragment"
        )
        .with(headers: {
          "Accept" => "application/json",
          "X-NEXT-GEN-CSO" => token
        })
    end

    it "JSON decodes and translates response body" do
      stub_request(:get, %r{\Ahttps://qa-pcl.uscourts.gov/})
        .to_return(body: '{"aKey": "value"}')
      response = session.get("path")
      expect(response).to eq(a_key: "value")
    end

    context "when JSON parsing fails" do
      before do
        stub_request(:get, %r{\Ahttps://qa-pcl.uscourts.gov/})
          .to_return(body: "<!DOCTYPE html>")
      end

      it "raises an exception with useful context" do
        expect {
          session.get("path")
        }.to raise_exception(
          PacerApi::ResponseError,
          %r{GET path}
        )
      end
    end
  end

  describe "post" do
    it "constructs request URL and headers" do
      session.post("fragment", {})
      expect(WebMock)
        .to have_requested(
          :post, "https://qa-pcl.uscourts.gov/pcl-public-api/rest/fragment"
        )
        .with(headers: {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "X-NEXT-GEN-CSO" => token
        })
    end

    it "translates and JSON encodes request document" do
      session.post("path", { a_key: "value" })
      expect(WebMock)
        .to have_requested(:post, /.*/)
        .with(body: JSON.generate("aKey" => "value"))
    end

    it "JSON decodes and translates response body" do
      stub_request(:post, %r{\Ahttps://qa-pcl.uscourts.gov/})
        .to_return(body: '{"aKey": "value"}')
      response = session.post("path", {})
      expect(response).to eq(a_key: "value")
    end

    context "when JSON parsing fails" do
      before do
        stub_request(:post, %r{\Ahttps://qa-pcl.uscourts.gov/})
          .to_return(body: "<!DOCTYPE html>")
      end

      it "raises an exception with useful context" do
        expect {
          session.post("path", { "key" => "value" })
        }.to raise_exception(
          PacerApi::ResponseError,
          %r[POST path with {"key"=>"value"}]
        )
      end
    end
  end

  describe "delete" do
    it "constructs request URL and headers" do
      session.delete("fragment")
      expect(WebMock)
        .to have_requested(
          :delete, "https://qa-pcl.uscourts.gov/pcl-public-api/rest/fragment"
        )
        .with(headers: {
          "Accept" => "application/json",
          "X-NEXT-GEN-CSO" => token
        })
    end

    it "returns true if deleted" do
      stub_request(:delete, %r{\Ahttps://qa-pcl.uscourts.gov/})
        .to_return(status: 204)
      expect(session.delete("path")).to be true
    end

    it "returns false if not deleted" do
      stub_request(:delete, %r{\Ahttps://qa-pcl.uscourts.gov/})
        .to_return(status: 500)
      expect(session.delete("path")).to be false
    end
  end

  describe "request" do
    it "performs an arbitrary request" do
      session.request(:get, "fragment") do |req|
        req.headers["Accept"] = "application/xml"
      end
      expect(WebMock)
        .to have_requested(
          :get, "https://qa-pcl.uscourts.gov/pcl-public-api/rest/fragment"
        )
        .with(headers: { "Accept" => "application/xml" })
    end
  end
end
