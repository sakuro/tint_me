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

  # Shortcut method to create a Style instance
  #
  # @param options [Hash] Style options to pass to Style.new
  # @return [Style] A new Style instance
  # @example
  #   blue = TIntMe[foreground: :blue]
  #   bold_red = TIntMe[foreground: :red, bold: true]
  def self.[](...)
    Style.new(...)
  end
end
