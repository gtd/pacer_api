# frozen_string_literal: true

require "pacer_api/authenticator"
require "pacer_api/immediate/case_search"

RSpec.describe "Immediate case search" do
  it "searches for cases", :vcr do
    session = PacerApi::Authenticator.new(
      PACER_LOGIN, PACER_PASSWORD, environment: :qa
    ).authenticate

    search = PacerApi::Immediate::CaseSearch.new(session, case_title: "THE")

    page = search.fetch(1)

    expect(page).not_to be_last
    expect(page.cases.length).to eq(54)
    expect(page.cases.first).to have_attributes(
      court_id: "azttca",
      case_id: 44236,
      case_number: 6062,
      case_title: "The Committee v. City of Northfield",
      case_year: 2003
    )

    page = search.fetch(2)

    expect(page).not_to be_last
    expect(page.cases.length).to eq(54)
    expect(page.cases.first).to have_attributes(
      court_id: "azttca",
      case_id: 23706,
      case_number: 4069,
      case_title: "The Farmers and v. St. Paul Fire and",
      case_year: 1997
    )
  end
end
