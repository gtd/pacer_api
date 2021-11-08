# frozen_string_literal: true

require "pacer/authenticator"
require "pacer/batch/case_search"

RSpec.describe "Batch case search" do
  it "searches for cases", :vcr do
    session = Pacer::Authenticator.new(
      PACER_LOGIN, PACER_PASSWORD, environment: :qa
    ).authenticate

    search = Pacer::Batch::CaseSearch.create(session, case_title: "Barnes")

    # sleep 5 # if regenerating this with blank VCR

    search.poll!

    expect(search).to be_completed
    expect(search.record_count).to eq(14)
    expect(search.download_fee).to be_within(0.001).of(0.1)

    download = search.download

    Pacer::Batch::CaseSearch.all(session).each(&:delete)

    expect(Pacer::Batch::CaseSearch.all(session)).to eq([])

    expect(download.cases.length).to eq(14)

    expect(download.cases.first).to have_attributes(
      court_id: "azt5ca",
      case_id: "9056",
      case_year: "1993",
      case_number: "3013",
      case_title: "Barnes Hospital v. Curtis C. Crawford, et al"
    )
  end

  it "downloads XML", :vcr do
    session = Pacer::Authenticator.new(
      PACER_LOGIN, PACER_PASSWORD, environment: :qa
    ).authenticate

    search = Pacer::Batch::CaseSearch.create(session, case_title: "Barnes")

    # sleep 5 # if regenerating this with blank VCR

    search.poll!

    expect(search).to be_completed

    xml = search.download_xml

    expect(xml).to match(%r{\A<\?xml version="1\.0" encoding="UTF-8"\?>})
  end
end
