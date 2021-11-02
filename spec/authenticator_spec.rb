# frozen_string_literal: true

require "pacer/authenticator"

RSpec.describe Pacer::Authenticator do
  subject(:authenticator) {
    described_class.new(login, password, environment: :qa)
  }

  describe "authentication", :vcr do
    context "when unsuccessful" do
      let(:login) { "kodos2024" }
      let(:password) { "Incorr3ct!" }

      it "raises an exception" do
        expect { authenticator.authenticate }
          .to raise_exception(Pacer::AuthenticationError)
          .with_message("Login Failed")
      end
    end

    context "when successful" do
      let(:login) { PACER_LOGIN }
      let(:password) { PACER_PASSWORD }

      it "returns a session object" do
        expect(authenticator.authenticate).to be_kind_of(Pacer::Session)
      end

      it "initializes the session object with the token and environment" do
        allow(Pacer::Session).to receive(:new)

        authenticator.authenticate

        expect(Pacer::Session)
          .to have_received(:new)
          .with(/\A[A-Za-z0-9]{128}\z/, environment: :qa)
      end
    end
  end
end
