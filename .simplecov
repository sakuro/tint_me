# frozen_string_literal: true

SimpleCov.start do
  # Coverage output directory
  coverage_dir "coverage"

  # Minimum coverage threshold
  minimum_coverage 90

  # Exclude files from coverage
  add_filter "/spec/"
  add_filter "/vendor/"
  add_filter "/bin/"
  add_filter "lib/tint_me/version.rb"

  # Group coverage by directory
  add_group "Main", "lib/tint_me"

  # Coverage formats
  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       SimpleCov::Formatter::HTMLFormatter,
                                                       SimpleCov::Formatter::SimpleFormatter
                                                     ])
end
