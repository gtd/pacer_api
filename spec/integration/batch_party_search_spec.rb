# frozen_string_literal: true

require "pacer/authenticator"
require "pacer/batch/party_search"

RSpec.describe "Batch party search" do
  it "searches for parties", :vcr do
    session = Pacer::Authenticator.new(
      PACER_LOGIN, PACER_PASSWORD, environment: :qa
    ).authenticate

    Pacer::Batch::PartySearch.all(session).each(&:delete)

    search = Pacer::Batch::PartySearch.create(session, last_name: "Barnesby")

    # sleep 60 # if regenerating this with blank VCR

    search.poll!

    expect(search).to be_completed

    download = search.download

    Pacer::Batch::PartySearch.all(session).each(&:delete)

    expect(Pacer::Batch::PartySearch.all(session)).to eq([])

    expect(download.parties.length).to eq(1)

    expect(download.parties.first).to have_attributes(
      court_id: "azttdc",
      case_id: "10842",
      case_year: "2007",
      case_number: "327",
      case_title: "Barnesby v. Barnes"
    )
  end
end