# frozen_string_literal: true

require "pacer/authenticator"
require "pacer/immediate/case_search"

RSpec.describe Pacer::Immediate::CaseSearch do
  subject(:case_search) {
    described_class.new(token, params, environment: :qa)
  }

  let(:token) {
    Pacer::Authenticator
      .new(PACER_LOGIN, PACER_PASSWORD, environment: :qa)
      .authenticate
      .token
  }

  describe "run", :vcr do
    subject(:result) { case_search.run }

    context "when there are no results" do
      let(:params) { { case_title: "Slartibartfast" } }

      it "exposes result metadata" do
        expect(result).to have_attributes(
          page: 1,
          total_pages: 0,
          total_elements: 0,
          last?: true
        )
      end
    end

    context "when there are results" do
      let(:params) { { case_title: "THE" } }

      it "exposes result metadata" do
        expect(result).to have_attributes(
          page: 1,
          total_pages: 51,
          total_elements: 2754,
          last?: false
        )
      end

      it "returns info for each case" do
        expect(result.cases.first).to have_attributes(
          court_id: "azttca",
          case_id: 44236,
          case_year: 2003,
          case_number: 6062,
          case_office: "0",
          case_type: "bap",
          case_title: "The Committee v. City of Northfield",
          date_filed: Date.new(2003, 9, 23),
          date_termed: Date.new(2004, 5, 3),
          nature_of_suit: "3422",
          jurisdiction_type: "Appellate",
          effective_date_closed: Date.new(2004, 5, 3),
          case_link: match(%r{\Ahttps://ecf.tc1a.aztc.uscourts.gov}),
          case_number_full: "0:2003bap06062"
        )
      end
    end

    context "when requesting a subsequent page" do
      subject(:result) { case_search.run(2) }

      let(:params) { { case_title: "THE" } }

      it "exposes result metadata" do
        expect(result).to have_attributes(
          page: 2,
          total_pages: 51,
          total_elements: 2754,
          last?: false
        )
      end

      it "returns info for each case" do
        expect(result.cases.first).to have_attributes(
          case_id: 23706,
          case_title: "The Farmers and v. St. Paul Fire and"
        )
      end
    end
  end
end
