# frozen_string_literal: true

require "pacer/response_translator"

RSpec.describe Pacer::ResponseTranslator do
  subject(:translator) { described_class }

  it "translates case of key" do
    input = { "topLevelKey" => "a_value" }
    expected = { top_level_key: "a_value" }

    expect(translator.translate(input)).to eq(expected)
  end

  it "recursively translates case of key in hash" do
    input = { "topLevelKey" => { "nestedKey" => "a_value" } }
    expected = { top_level_key: { nested_key: "a_value" } }

    expect(translator.translate(input)).to eq(expected)
  end

  it "recursively translates case of key in array" do
    input = { "topLevelKey" => [{ "nestedKey" => "a_value" }] }
    expected = { top_level_key: [{ nested_key: "a_value" }] }

    expect(translator.translate(input)).to eq(expected)
  end

  it "translates dates from YYYY-MM-DD" do
    input = { "date" => "2001-02-03" }
    expected = { date: Date.new(2001, 2, 3) }

    expect(translator.translate(input)).to eq(expected)
  end

  it "translates times from YYYY-MM-DDTHH:MM:SS..." do
    input = { "time" => "2021-01-08T15:19:42.012-06:00" }
    expected = Time.new(2021, 1, 8, 15, 19, 42.012, "-06:00")
    decoded = translator.translate(input)

    expect(decoded.fetch(:time)).to be_within(0.0001).of(expected)
  end
end
