# frozen_string_literal: true

require_relative "lib/tint_me/version"

Gem::Specification.new do |spec|
  spec.name = "tint_me"
  spec.version = TIntMe::VERSION
  spec.authors = ["OZAWA Sakuro"]
  spec.email = ["10973+sakuro@users.noreply.github.com"]

  spec.summary = "tint_me"
  spec.description = "tint_me"
  spec.homepage = "https://github.com/sakuro/tint_me"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.9"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}.git"
    spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "zeitwerk", "~> 2.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
