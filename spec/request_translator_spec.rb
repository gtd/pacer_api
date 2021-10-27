# frozen_string_literal: true

require "pacer/api/request_translator"

RSpec.describe Pacer::Api::RequestTranslator do
  subject(:translator) { described_class }

  it "translates case of key" do
    input = { top_level_key: "a_value" }
    expected = { "topLevelKey" => "a_value" }

    expect(translator.translate(input)).to eq(expected)
  end

  it "recursively translates case of key in hash" do
    input = { top_level_key: { nested_key: "a_value" } }
    expected = { "topLevelKey" => { "nestedKey" => "a_value" } }

    expect(translator.translate(input)).to eq(expected)
  end

  it "recursively translates case of key in array" do
    input = { top_level_key: [{ nested_key: "a_value" }] }
    expected = { "topLevelKey" => [{ "nestedKey" => "a_value" }] }

    expect(translator.translate(input)).to eq(expected)
  end

  it "translates dates to YYYY-MM-DD" do
    input = { date: Date.new(2001, 2, 3) }
    expected = { "date" => "2001-02-03" }

    expect(translator.translate(input)).to eq(expected)
  end
end
