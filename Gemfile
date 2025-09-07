# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development, :test do
  gem "irb"
  gem "repl_type_completor"
  gem "rake"
end

group :development do
  # RuboCop
  gem "docquet", github: "sakuro/docquet" # An opionated RuboCop config tool
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"

  # YARD
  gem "redcarpet"
  gem "yard", github: "lsegal/yard" # Version with Data.define support
end

group :test do
  # RSpec & SimpleCov
  gem "rspec"
  gem "simplecov"
end
