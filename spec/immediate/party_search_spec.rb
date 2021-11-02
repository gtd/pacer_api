# frozen_string_literal: true

require "pacer/authenticator"
require "pacer/immediate/party_search"

RSpec.describe Pacer::Immediate::PartySearch do
  subject(:party_search) {
    described_class.new(session, params)
  }

  let(:session) {
    Pacer::Authenticator
      .new(PACER_LOGIN, PACER_PASSWORD, environment: :qa)
      .authenticate
  }

  describe "search", :vcr do
    subject(:result) { party_search.search }

    context "when there are no results" do
      let(:params) { { last_name: "Slartibartfast" } }

      it "exposes result metadata" do
        expect(result).to have_attributes(
          page: 1,
          total_pages: 1,
          last?: true
        )
      end
    end

    context "when there are results" do
      let(:params) { { last_name: "Smith" } }

      it "exposes result metadata" do
        expect(result).to have_attributes(
          page: 1,
          total_pages: 101,
          last?: false
        )
      end

      it "returns info for each party" do
        expect(result.parties.first).to have_attributes(
          court_id: "azttdc",
          case_id: 12153,
          case_year: 2005,
          case_number: 1234,
          last_name: "Smith",
          first_name: "Henry",
          middle_name: " ",
          generation: " ",
          party_type: "pty",
          party_role: "dft",
          jurisdiction_type: "Civil",
          nature_of_suit: "190",
          date_filed: Date.new(2008, 4, 9),
          case_number_full: "1:2005cv01234",
          case_office: "1",
          case_type: "cv",
          case_title: "v. Thomas et al"
        )
      end

      it "returns court case info" do
        expect(result.parties.first.court_case).to have_attributes(
          court_id: "azttdc",
          case_id: 12153,
          case_year: 2005,
          case_number: 1234,
          case_office: "1",
          case_type: "cv",
          case_title: "v. Thomas et al",
          date_filed: Date.new(2008, 4, 9),
          nature_of_suit: "190",
          jurisdiction_type: "Civil",
          case_link: match(%r{\Ahttps://ecf.tc1d.aztc.uscourts.gov}),
          case_number_full: "1:2005cv01234"
        )
      end
    end

    context "when requesting a subsequent page" do
      subject(:result) { party_search.search(2) }

      let(:params) { { last_name: "Smith" } }

      it "exposes result metadata" do
        expect(result).to have_attributes(
          page: 2,
          total_pages: 101,
          last?: false
        )
      end

      it "returns info for each party" do
        expect(result.parties.first).to have_attributes(
          case_id: 18029,
          case_title: "Johnson v. Smith"
        )
      end
    end
  end
end
