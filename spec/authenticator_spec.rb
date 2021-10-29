# frozen_string_literal: true

require "pacer/authenticator"

RSpec.describe Pacer::Authenticator do
  subject(:authenticator) {
    described_class.new(login, password, environment: :qa)
  }

  describe "authentication response", :vcr do
    subject(:response) { authenticator.authenticate }

    context "when unsuccessful" do
      let(:login) { "kodos2024" }
      let(:password) { "Incorr3ct!" }

      it "exposes failure" do
        expect(response).not_to be_success
      end
    end

    context "when successful" do
      let(:login) { PACER_LOGIN }
      let(:password) { PACER_PASSWORD }

      it "exposes success" do
        expect(response).to be_success
      end

      it "returns the sign on token" do
        expect(response.token).to match(/\A[A-Za-z0-9]{128}\z/)
      end
    end
  end
end
