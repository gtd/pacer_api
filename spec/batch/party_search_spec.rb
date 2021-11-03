# frozen_string_literal: true

require "pacer/authenticator"
require "pacer/batch/party_search"

RSpec.describe Pacer::Batch::PartySearch do
  subject(:search) { described_class.new(session, status_doc) }

  let(:session) { instance_double(Pacer::Session) }
  let(:status_doc) {
    {
      report_id: 1078,
      status: "RUNNING"
    }
  }

  describe ".create" do
    let(:search_params) { { last_name: "Slartibartfast" } }

    before do
      allow(session).to receive(:post).and_return(status_doc)
    end

    it "starts a search" do
      described_class.create(session, search_params)

      expect(session).to have_received(:post)
        .with("parties/download", search_params)
    end

    it "instantiates an instance with session and response" do
      allow(described_class).to receive(:new)

      described_class.create(session, search_params)

      expect(described_class).to have_received(:new)
        .with(session, status_doc)
    end

    it "returns the corresponding instance" do
      party_job = instance_double(described_class)
      allow(described_class).to receive(:new).and_return(party_job)

      expect(described_class.create(session, search_params)).to eq(party_job)
    end
  end

  describe ".all" do
    let(:list_doc) {
      {
        receipt: nil,
        page_info: {
          number: 0,
          size: 54,
          total_pages: 1,
          total_elements: 5,
          number_of_elements: 5,
          first: true,
          last: true
        },
        content: [status_doc]
      }
    }

    before do
      allow(session).to receive(:get).and_return(list_doc)
    end

    it "fetches the list" do
      described_class.all(session)

      expect(session).to have_received(:get).with("parties/reports")
    end

    it "instantiates an instance for each item" do
      allow(described_class).to receive(:new)

      described_class.all(session)

      expect(described_class).to have_received(:new)
        .with(session, status_doc)
    end

    it "returns an instance for each item" do
      party_job = instance_double(described_class)
      allow(described_class).to receive(:new).and_return(party_job)

      expect(described_class.all(session)).to eq([party_job])
    end
  end

  describe "completed?" do
    it "is initially false" do
      expect(search).not_to be_completed
    end

    it "is false after polling a still-running job" do
      response_doc = {
        report_id: 1078,
        status: "RUNNING"
      }
      allow(session).to receive(:get).and_return(response_doc)

      search.poll!

      expect(search).not_to be_completed
    end

    it "is true after polling a completed job" do
      response_doc = {
        report_id: 1078,
        status: "COMPLETED"
      }
      allow(session).to receive(:get).and_return(response_doc)

      search.poll!

      expect(search).to be_completed
    end
  end

  describe "poll!" do
    it "requests a new batch job status" do
      response_doc = {
        report_id: 1078,
        status: "RUNNING"
      }
      allow(session).to receive(:get).and_return(response_doc)

      search.poll!

      expect(session).to have_received(:get).with("parties/download/status/1078")
    end
  end

  describe "download" do
    let(:response_doc) {
      {
        content: [{
          court_id: "azttdc",
          case_id: "10842",
          case_year: "2007",
          case_number: "327",
          case_office: "0",
          case_type: "cv",
          case_title: "Barnesby v. Barnes",
          date_filed: Date.new(2007, 8, 27),
          last_name: "Barnesby",
          first_name: "Billy",
          party_type: "pty",
          party_role: "pla",
          nature_of_suit: "110",
          case_link: "https://ecf.tc1d.aztc.uscourts.gov/blah",
          case_number_full: "0:2007cv00327"
        }],
        receipt: {
          billable_pages: 1,
          fee: 0.1,
          login_id: "<LOGIN>",
          client_code: "",
          firm_id: "",
          search: "All Courts; Name Barnesby; Batch",
          description: "All Court Types Party Search",
          cso_id: 4697705
        }
      }
    }

    before do
      allow(session).to receive(:get).and_return(response_doc)
    end

    it "fetches the report" do
      search.download

      expect(session).to have_received(:get).with("parties/download/1078")
    end

    it "returns info for each party" do
      result = search.download
      expect(result.parties.first).to have_attributes(
        court_id: "azttdc",
        case_id: "10842",
        case_year: "2007",
        case_number: "327",
        case_office: "0",
        case_type: "cv",
        case_title: "Barnesby v. Barnes",
        date_filed: Date.new(2007, 8, 27),
        last_name: "Barnesby",
        first_name: "Billy",
        party_type: "pty",
        party_role: "pla",
        nature_of_suit: "110",
        case_link: "https://ecf.tc1d.aztc.uscourts.gov/blah",
        case_number_full: "0:2007cv00327"
      )
    end
  end

  describe "delete" do
    before do
      allow(session).to receive(:delete)
    end

    it "deletes the job" do
      search.delete

      expect(session).to have_received(:delete).with("parties/reports/1078")
    end
  end
end
