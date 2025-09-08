# frozen_string_literal: true

require "zeitwerk"
require_relative "tint_me/version"

# TIntMe module
module TIntMe
  # Setup Zeitwerk loader
  loader = Zeitwerk::Loader.for_gem
  loader.inflector.inflect(
    "tint_me" => "TIntMe"
  )
  loader.ignore("#{__dir__}/tint_me/version.rb")
  loader.setup
end
