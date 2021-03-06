# frozen_string_literal: true

require "pacer_api/authenticator"
require "pacer_api/batch/party_search"

RSpec.describe "Batch party search" do
  it "searches for parties", :vcr do
    session = PacerApi::Authenticator.new(
      PACER_LOGIN, PACER_PASSWORD, environment: :qa
    ).authenticate

    PacerApi::Batch::PartySearch.all(session).each(&:delete)

    search = PacerApi::Batch::PartySearch.create(session, last_name: "Barnesby")

    # sleep 60 # if regenerating this with blank VCR

    search.poll!

    expect(search).to be_completed
    expect(search.record_count).to eq(1)
    expect(search.download_fee).to be_within(0.001).of(0.1)

    download = search.download

    PacerApi::Batch::PartySearch.all(session).each(&:delete)

    expect(PacerApi::Batch::PartySearch.all(session)).to eq([])

    expect(download.parties.length).to eq(1)

    expect(download.parties.first).to have_attributes(
      court_id: "azttdc",
      case_id: "10842",
      case_year: "2007",
      case_number: "327",
      case_title: "Barnesby v. Barnes"
    )
  end

  it "downloads XML", :vcr do
    session = PacerApi::Authenticator.new(
      PACER_LOGIN, PACER_PASSWORD, environment: :qa
    ).authenticate

    search = PacerApi::Batch::PartySearch.create(session, last_name: "Barnesby")

    # sleep 60 # if regenerating this with blank VCR

    search.poll!

    expect(search).to be_completed

    xml = search.download_xml

    expect(xml).to match(%r{\A<\?xml version="1\.0" encoding="UTF-8"\?>})
  end
end
