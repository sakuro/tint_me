# frozen_string_literal: true

require_relative "lib/tint_me/version"

Gem::Specification.new do |spec|
  spec.name = "tint_me"
  spec.version = TIntMe::VERSION
  spec.authors = ["OZAWA Sakuro"]
  spec.email = ["10973+sakuro@users.noreply.github.com"]

  spec.summary = "Functional terminal text styling with composable ANSI colors and effects"
  spec.description = <<~DESC
    A Ruby library for terminal text styling with ANSI colors and effects.
    Provides an elegant, functional API with immutable style objects that can be
    composed using the >> operator. Supports standard colors, hex values,
    and comprehensive text effects including bold, faint, italic, underline,
    overline, blink, inverse, and concealed text. Features type-safe argument
    validation using dry-schema and dry-types.
  DESC
  spec.homepage = "https://github.com/sakuro/tint_me"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.9"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}.git"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) {
    %w[
      CHANGELOG.md
      LICENSE.txt
      README.md
    ] + Dir.glob("lib/**/*.rb") + Dir.glob("sig/**/*.rbs")
  }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "dry-schema", "~> 1.13"
  spec.add_dependency "dry-types", "~> 1.7"
  spec.add_dependency "zeitwerk", "~> 2.6"
end
