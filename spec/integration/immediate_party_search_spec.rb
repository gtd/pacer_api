# frozen_string_literal: true

require "pacer_api/authenticator"
require "pacer_api/immediate/party_search"

RSpec.describe "Immediate party search" do
  it "searches for parties", :vcr do
    session = PacerApi::Authenticator.new(
      PACER_LOGIN, PACER_PASSWORD, environment: :qa
    ).authenticate

    search = PacerApi::Immediate::PartySearch.new(session, last_name: "Smith")

    page = search.fetch(1)

    expect(page).not_to be_last
    expect(page.parties.length).to eq(54)
    expect(page.parties.first).to have_attributes(
      court_id: "azttdc",
      case_id: 12153,
      case_number: 1234,
      case_year: 2005,
      last_name: "Smith",
      first_name: "Henry"
    )

    page = search.fetch(2)

    expect(page).not_to be_last
    expect(page.parties.length).to eq(54)
    expect(page.parties.first).to have_attributes(
      court_id: "azttdc",
      case_id: 18029,
      case_number: 456,
      case_year: 2008,
      last_name: "Smith",
      first_name: "Barry"
    )
  end
end
