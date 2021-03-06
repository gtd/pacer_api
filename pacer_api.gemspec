# frozen_string_literal: true

require_relative "lib/pacer_api/version"

Gem::Specification.new do |spec|
  spec.name          = "pacer_api"
  spec.version       = PacerApi::VERSION
  spec.authors       = ["Paul Battley"]
  spec.email         = ["pbattley@gmail.com"]
  spec.license       = "MIT"

  spec.summary       = "PACER Case Locator API"
  spec.description   = "Interface to the PACER Case Locator API"
  spec.homepage      = "https://github.com/gtd/pacer_api"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) {
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "faraday"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
