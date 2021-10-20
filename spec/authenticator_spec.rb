# frozen_string_literal: true

require "pacer/api/authenticator"

RSpec.describe Pacer::Api::Authenticator do
  subject(:authenticator) {
    described_class.new(login, password, environment: :qa)
  }

  describe "authentication response" do
    subject(:response) { authenticator.authenticate }

    context "when unsuccessful" do
      around do |example|
        VCR.use_cassette("login_incorrect") { example.call }
      end

      let(:login) { "kodos2024" }
      let(:password) { "Incorr3ct!" }

      it { is_expected.not_to be_success }
    end

    context "when successful" do
      around do |example|
        VCR.use_cassette("login_correct") { example.call }
      end

      let(:login) { PACER_LOGIN }
      let(:password) { PACER_PASSWORD }

      it { is_expected.to be_success }

      it "returns the sign on token" do
        expect(response.token).to eq(
          "wFlIvajsjMsftBaPkMHnzFKaYvZ0W0FvunhGU4n1btEYFZ7TPDk0Zx864WfxAqZw" \
          "5dzP2sa6JmVnpc5PJKvbnkn9LixLkWAXV6ouj5Ubi8HzN3RPsp6BRNS1PvSkluB1"
        )
      end
    end
  end
end
