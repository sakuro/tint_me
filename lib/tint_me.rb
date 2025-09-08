# frozen_string_literal: true

require "zeitwerk"
require_relative "tint_me/version"

# TIntMe - Functional terminal text styling with composable ANSI colors and effects
#
# TIntMe provides an elegant, functional API for terminal text styling using ANSI escape codes.
# It features immutable Style objects that can be composed using the >> operator, supporting
# standard colors, hex values, and comprehensive text effects.
#
# @example Basic styling
#   require "tint_me"
#
#   # Create styles
#   red = TIntMe[foreground: :red]
#   bold = TIntMe[bold: true]
#
#   # Apply styling
#   puts red.call("Error!")
#   puts bold["Important"]
#
# @example Style composition
#   base = TIntMe[foreground: :blue]
#   emphasis = TIntMe[bold: true, underline: true]
#   styled = base >> emphasis
#   puts styled.call("Highlighted text")
#
# @example Hex colors
#   custom = TIntMe[foreground: "#FF6B35", background: "#F7931E"]
#   puts custom.call("Custom colors")
#
# @see Style
# @see Style#initialize
# @author OZAWA Sakuro
module TIntMe
  # Setup Zeitwerk loader
  loader = Zeitwerk::Loader.for_gem
  loader.inflector.inflect(
    "tint_me" => "TIntMe",
    "sgr_builder" => "SGRBuilder"
  )
  loader.ignore("#{__dir__}/tint_me/version.rb")
  loader.setup

  # Shortcut method to create a Style instance with the given options
  #
  # This is a convenience method that passes all arguments directly to Style.new.
  # Accepts the same keyword arguments as Style#initialize.
  #
  # @return [Style] A new Style instance
  # @see Style#initialize
  # @example Basic usage
  #   blue = TIntMe[foreground: :blue]
  #   bold_red = TIntMe[foreground: :red, bold: true]
  #   puts blue.call("Hello")  # => blue "Hello"
  # @example Immediate styling
  #   puts TIntMe[foreground: :green, italic: true]["Success!"]
  def self.[](...)
    Style.new(...)
  end
end
