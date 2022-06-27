# frozen_string_literal: true

require "pacer_api/authenticator"
require "pacer_api/immediate/party_search"

RSpec.describe PacerApi::Immediate::PartySearch do
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
        .with("parties/find?page=0", search_params)
    end

    it "requests the specified page" do
      search.fetch(99)

      expect(session).to have_received(:post)
        .with("parties/find?page=99", search_params)
    end

    context "when there are no results" do
      subject(:page) { search.fetch }

      let(:response_document) {
        {
          receipt: {
            transaction_date: Time.new(2021, 10, 29, 10, 15, 40.877, "-05:00"),
            billable_pages: 1,
            login_id: "<LOGIN>",
            client_code: "",
            firm_id: "",
            search: "All Courts; Name Slartibartfast; Page: 2",
            description: "All Court Types Party Search",
            cso_id: 4697705,
            report_id: "4777bfa5-cc43-4962-be66-8520098aa2d0",
            search_fee: ".10"
          },
          page_info: {
            number: 1,
            size: 54,
            total_pages: 1,
            total_elements: 4,
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
          total_pages: 1,
          last?: true
        )
      end

      it "has no parties" do
        expect(page.parties).to eq([])
      end
    end

    context "when there are results" do
      subject(:page) { search.fetch }

      let(:response_document) {
        {
          receipt: {
            transaction_date: Time.new(2021, 10, 29, 10, 15, 33.279, "-05:00"),
            billable_pages: 1,
            login_id: "<LOGIN>",
            client_code: "",
            firm_id: "",
            search: "All Courts; Name Smith; Page: 2",
            description: "All Court Types Party Search",
            cso_id: 4697705,
            report_id: "9c4a8e55-6c7f-48df-9f6c-0fb22ec7e507",
            search_fee: ".10"
          },
          page_info: {
            number: 1,
            size: 54,
            total_pages: 101,
            total_elements: 5401,
            number_of_elements: 54,
            first: false,
            last: false
          },
          content: [{
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
            court_case: {
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
              case_link: "https://ecf.tc1d.aztc.uscourts.gov/blah",
              case_number_full: "1:2005cv01234"
            },
            nature_of_suit: "190",
            date_filed: Date.new(2008, 4, 9),
            case_number_full: "1:2005cv01234",
            case_office: "1",
            case_type: "cv",
            case_title: "v. Thomas et al"
          }],
          master_case: nil
        }
      }

      it "exposes result metadata" do
        expect(page).to have_attributes(
          page: 1,
          total_pages: 101,
          last?: false
        )
      end

      it "returns info for each party" do
        expect(page.parties.first).to have_attributes(
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
        expect(page.parties.first.court_case).to have_attributes(
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
          case_link: "https://ecf.tc1d.aztc.uscourts.gov/blah",
          case_number_full: "1:2005cv01234"
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
              "Party Name cross validation",
              "Wildcard character not allowed in first character of search value."
            ]
          }]
        }
      }

      it "has no parties" do
        expect(page.parties).to be_empty
      end

      it "exposes error messages" do
        expect(page.errors).to eq(
          [
            "Party Name cross validation",
            "Wildcard character not allowed in first character of search value."
          ]
        )
      end
    end
  end
end
