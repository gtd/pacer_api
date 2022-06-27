# frozen_string_literal: true

require "pacer_api/authenticator"
require "pacer_api/immediate/case_search"

RSpec.describe PacerApi::Immediate::CaseSearch do
  subject(:search) { described_class.new(session, search_params) }

  let(:session) { instance_double(PacerApi::Session) }
  let(:search_params) { { case_title: "Slartibartfast" } }
  let(:response_document) { {} }

  describe "fetch" do
    before do
      allow(session).to receive(:post).and_return(response_document)
    end

    it "requests page 0 by default" do
      search.fetch

      expect(session).to have_received(:post)
        .with("cases/find?page=0", search_params)
    end

    it "requests the specified page" do
      search.fetch(99)

      expect(session).to have_received(:post)
        .with("cases/find?page=99", search_params)
    end

    context "when there are no results" do
      subject(:page) { search.fetch }

      let(:response_document) {
        {
          receipt: {
            transaction_date: Time.new(2021, 10, 29, 9, 14, 43.778, "-05:00"),
            billable_pages: 1,
            login_id: "<LOGIN>",
            client_code: "",
            firm_id: "",
            search: "All Courts; Case Title Slartibartfast",
            description: "All Court Types Case Search",
            cso_id: 4697705,
            report_id: "fad137c8-f5e1-4dd6-aeb3-52482e3a595e",
            search_fee: ".10"
          },
          page_info: {
            number: 1,
            size: 54,
            total_pages: 0,
            total_elements: 0,
            number_of_elements: 0,
            first: false,
            last: true
          },
          content: [],
          master_case: nil
        }
      }

      it "exposes result metadata" do
        expect(page).to have_attributes(
          page: 1,
          total_pages: 0,
          total_elements: 0,
          last?: true
        )
      end

      it "has no cases" do
        expect(page.cases).to eq([])
      end
    end

    context "when there are results" do
      subject(:page) { search.fetch }

      let(:response_document) {
        {
          receipt: {
            transaction_date: Time.new(2021, 10, 29, 9, 14, 46.577, "-05:00"),
            billable_pages: 0,
            login_id: "<LOGIN>",
            client_code: "",
            firm_id: "",
            search: "All Courts; Case Title THE; Page: 2",
            description: "All Court Types Case Search",
            cso_id: 4697705,
            report_id: "1007bd14-42de-41b0-9fc1-0fc77bad79bd",
            search_fee: ".00"
          },
          page_info: {
            number: 1,
            size: 54,
            total_pages: 51,
            total_elements: 2754,
            number_of_elements: 54,
            first: false,
            last: false
          },
          content: [{
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
            case_link: "https://ecf.tc1a.aztc.uscourts.gov/blah",
            case_number_full: "0:2003bap06062"
          }],
          master_case: nil
        }
      }

      it "exposes result metadata" do
        expect(page).to have_attributes(
          page: 1,
          total_pages: 51,
          total_elements: 2754,
          last?: false
        )
      end

      it "returns info for each case" do
        expect(page.cases.first).to have_attributes(
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
          case_link: "https://ecf.tc1a.aztc.uscourts.gov/blah",
          case_number_full: "0:2003bap06062"
        )
      end

      it "has no errors" do
        expect(page.errors).to be_empty
      end
    end

    context "when the response is an error" do
      subject(:page) { search.fetch }

      let(:response_document) {
        {
          error: [{
            field: "",
            messages: [
              "Case Title cross validation",
              "Wildcard character not allowed in first character of search value."
            ]
          }]
        }
      }

      it "has no cases" do
        expect(page.cases).to be_empty
      end

      it "exposes error messages" do
        expect(page.errors).to eq(
          [
            "Case Title cross validation",
            "Wildcard character not allowed in first character of search value."
          ]
        )
      end
    end
  end
end
