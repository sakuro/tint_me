# frozen_string_literal: true

require "dry-types"

module TIntMe
  class Style
    # Type definitions for Style attributes using dry-types
    module Types
      include Dry.Types()

      # Standard ANSI color names
      ColorSymbol = Symbol.enum(
        :default, :reset, :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white, :gray
      )
      public_constant :ColorSymbol

      # Hex color strings (3 or 6 digits, with or without #)
      ColorString = String.constrained(format: /\A#?\h{3}(?:\h{3})?\z/)
      public_constant :ColorString

      Color = ColorSymbol | ColorString
      public_constant :Color

      BooleanOption = (Bool | Symbol.enum(:reset)).optional
      public_constant :BooleanOption

      UnderlineOption = (Bool | Symbol.enum(:double, :reset)).optional
      public_constant :UnderlineOption
    end
  end
end
