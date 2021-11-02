# frozen_string_literal: true

require "vcr"
require "webmock"

PACER_LOGIN = ENV.fetch("PACER_LOGIN", "validlogin")
PACER_PASSWORD = ENV.fetch("PACER_PASSWORD", "Val1dPassword!")

VCR.configure do |config|
  config.cassette_library_dir =
    File.expand_path("../fixtures/vcr_cassettes", __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data("<LOGIN>") { PACER_LOGIN }
  config.filter_sensitive_data("<PASSWORD>") { PACER_PASSWORD }
  config.configure_rspec_metadata!
end
