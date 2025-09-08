# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "yard"
YARD::Rake::YardocTask.new(:doc)

require "rake/clean"
CLEAN.include("coverage", ".yardoc", "docs/api", ".rspec_status")
CLOBBER.include("pkg")

task default: %i[spec rubocop]
