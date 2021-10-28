# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new

desc "Run the specs."
RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = false
end

task default: %i[rubocop spec]
