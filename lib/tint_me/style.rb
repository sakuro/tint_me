# frozen_string_literal: true

require "paint"

module TIntMe
  Style = Data.define(
    :foreground,
    :background,
    :inverse,
    :bold,
    :faint,
    :underline,
    :overline,
    :blink,
    :italic,
    :hide
  )

  # A style class that wraps Paint gem functionality for applying ANSI colors and text effects.
  #
  # This class provides an immutable way to define and compose terminal styling options.
  # It supports foreground/background colors, text decorations (bold, italic, underline, etc.),
  # and composition via the >> operator for layering styles.
  #
  # @example Basic usage
  #   style = Style.new(foreground: :red, bold: true)
  #   puts style.call("Hello")  # or style["Hello"] or style.("Hello")
  #
  # @example Style composition
  #   base = Style.new(foreground: :blue)
  #   emphasis = Style.new(bold: true, underline: true)
  #   combined = base >> emphasis
  #   puts combined.call("Styled text")  # or combined["Styled text"] or combined.("Styled text")
  #
  # @example Color and decoration options
  #   Style.new(
  #     foreground: :red,           # :default, :red, :green, :blue, etc. or hex "#FF0000"
  #     background: :yellow,        # same as foreground
  #     bold: true,                 # nil (unset), false (off), true (on)
  #     faint: false,               # mutually exclusive with bold
  #     underline: :double,         # nil, false, true, :double
  #     italic: true,               # nil, false, true
  #     inverse: true,              # nil, false, true
  #     # ... other boolean effects: overline, blink, hide
  #   )
  class Style
    # @!attribute [r] foreground
    #   @return [Symbol, String] The foreground color (:red, :blue, hex "#FF0000", etc.)

    # @!attribute [r] background
    #   @return [Symbol, String] The background color (same format as foreground)

    # @!attribute [r] inverse
    #   @return [nil, true, false] Whether to reverse foreground/background colors

    # @!attribute [r] bold
    #   @return [nil, true, false] Whether text is bold (mutually exclusive with faint)

    # @!attribute [r] faint
    #   @return [nil, true, false] Whether text is faint/dim (mutually exclusive with bold)

    # @!attribute [r] underline
    #   @return [nil, true, false, :double] Underline decoration type

    # @!attribute [r] overline
    #   @return [nil, true, false] Whether text has overline decoration

    # @!attribute [r] blink
    #   @return [nil, true, false] Whether text blinks

    # @!attribute [r] italic
    #   @return [nil, true, false] Whether text is italic

    # @!attribute [r] hide
    #   @return [nil, true, false] Whether text is hidden/concealed
    # Initialize a new Style with the given attributes
    #
    # @param foreground [Symbol, String] Foreground color. Accepts color names (:red, :green, :blue, etc.),
    #   :default for terminal default, or hex strings ("#FF0000", "FF0000")
    # @param background [Symbol, String] Background color. Same format as foreground
    # @param inverse [nil, true, false] Reverse foreground/background colors
    # @param bold [nil, true, false] Bold text (mutually exclusive with faint)
    # @param faint [nil, true, false] Faint/dim text (mutually exclusive with bold)
    # @param underline [nil, true, false, :double] Underline decoration
    # @param overline [nil, true, false] Overline decoration
    # @param blink [nil, true, false] Blinking text
    # @param italic [nil, true, false] Italic text
    # @param hide [nil, true, false] Hidden/concealed text
    # @raise [ArgumentError] If both bold and faint are true
    # @raise [ArgumentError] If any parameter has invalid type or value
    # @example Valid usage
    #   Style.new(foreground: :red, bold: true)
    #   Style.new(underline: :double, background: "#FF0000")
    # @example Invalid usage (raises ArgumentError)
    #   Style.new(foreground: 123)        # Invalid color type
    #   Style.new(bold: "true")           # Invalid boolean type
    #   Style.new(underline: :invalid)    # Invalid underline option
    #   Style.new(bold: true, faint: true) # Mutually exclusive options
    def initialize(
      foreground: :default,
      background: :default,
      inverse: nil,
      bold: nil,
      faint: nil,
      underline: nil,
      overline: nil,
      blink: nil,
      italic: nil,
      hide: nil
    )
      # Schema validation
      result = Schema.call({
        foreground:,
        background:,
        inverse:,
        bold:,
        faint:,
        underline:,
        overline:,
        blink:,
        italic:,
        hide:
      })

      raise ArgumentError, result.errors.to_h unless result.success?

      # Handle bold/faint mutual exclusion
      if bold && faint
        raise ArgumentError, "Cannot specify both bold and faint simultaneously"
      end

      super
    end

    # Apply the style to the given text using Paint gem
    #
    # @param text [String] The text to apply styling to
    # @return [String] The styled text with ANSI escape codes, or original text if no styles are set
    # @example
    #   style = Style.new(foreground: :red, bold: true)
    #   style.call("Hello")  # => "\e[31;1mHello\e[0m"
    #   style["World"]       # => "\e[31;1mWorld\e[0m" (alias)
    def call(text)
      styles = build_styles
      if styles.empty?
        text
      else
        Paint[text, *styles]
      end
    end

    alias [] call

    # Compose this style with another style, creating a new Style instance.
    # The right-hand style takes precedence for non-nil values.
    # Handles bold/faint mutual exclusion automatically.
    #
    # @param other [Style] The style to compose with this one
    # @return [Style] A new Style instance with composed attributes
    # @example Basic composition
    #   base = Style.new(foreground: :red, bold: true)
    #   overlay = Style.new(background: :blue, underline: true)
    #   result = base >> overlay  # => red text, blue background, bold and underlined
    # @example Bold/faint handling
    #   bold_style = Style.new(bold: true)
    #   faint_style = Style.new(faint: true)
    #   result = bold_style >> faint_style  # => faint overrides bold
    def >>(other)
      # Handle bold/faint mutual exclusion in composition
      composed_bold = other.bold.nil? ? bold : other.bold
      composed_faint = other.faint.nil? ? faint : other.faint

      # If other explicitly sets bold, clear faint; if other explicitly sets faint, clear bold
      if other.bold == true
        composed_faint = false
      elsif other.faint == true
        composed_bold = false
      end

      Style.new(
        foreground: other.foreground == :default ? foreground : other.foreground,
        background: other.background == :default ? background : other.background,
        inverse: other.inverse.nil? ? inverse : other.inverse,
        bold: composed_bold,
        faint: composed_faint,
        underline: other.underline.nil? ? underline : other.underline,
        overline: other.overline.nil? ? overline : other.overline,
        blink: other.blink.nil? ? blink : other.blink,
        italic: other.italic.nil? ? italic : other.italic,
        hide: other.hide.nil? ? hide : other.hide
      )
    end

    private def build_styles
      styles = []

      # Add colors individually
      if foreground != :default && background != :default
        styles << foreground
        styles << background
      elsif foreground != :default
        styles << foreground
      elsif background != :default
        styles << nil
        styles << background
      end

      # Add text decorations
      case underline
      when true
        styles << :underline
      when :double
        styles << :double_underline
      when nil, false
        # No underline
      else
        raise ArgumentError, "Invalid underline value: #{underline.inspect}"
      end

      styles << :overline if overline == true
      styles << :bold if bold == true
      styles << :faint if faint == true
      styles << :blink if blink == true
      styles << :italic if italic == true
      styles << :inverse if inverse == true
      styles << :hide if hide == true

      styles
    end
  end
end
