# frozen_string_literal: true

require_relative "lib/pacer/api/version"

Gem::Specification.new do |spec|
  spec.name          = "pacer-api"
  spec.version       = Pacer::Api::VERSION
  spec.authors       = ["Paul Battley"]
  spec.email         = ["pbattley@gmail.com"]

  spec.summary       = "PACER Case Locator API"
  spec.description   = "Interface to the PACER Case Locator API"
  spec.homepage      = "https://github.com/busbk/pacer-api"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rubocop"
end
