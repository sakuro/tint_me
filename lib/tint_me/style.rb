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
      foreground: nil,
      background: nil,
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
    # == Composition Rules
    #
    # For `a >> b`, the resulting value for each attribute is determined by:
    #
    # <table>
    #   <tr>
    #     <th>b's value</th>
    #     <th>Result</th>
    #     <th>Description</th>
    #   </tr>
    #   <tr>
    #     <td><code>nil</code></td>
    #     <td><code>a</code>'s value</td>
    #     <td>Preserves the original value</td>
    #   </tr>
    #   <tr>
    #     <td><code>:reset</code></td>
    #     <td><code>nil</code></td>
    #     <td>Explicitly resets to no styling</td>
    #   </tr>
    #   <tr>
    #     <td>any other</td>
    #     <td><code>b</code>'s value</td>
    #     <td>Adopts the new value</td>
    #   </tr>
    # </table>
    #
    # This applies to all attributes: colors (foreground, background) and
    # style attributes (bold, italic, underline, inverse, overline, blink, hide).
    #
    # @param other [Style] The style to compose with this one
    # @return [Style] A new Style instance with composed attributes
    #
    # @example Basic composition
    #   base = Style.new(foreground: :red, bold: true)
    #   overlay = Style.new(background: :blue, underline: true)
    #   result = base >> overlay  # => red text, blue background, bold and underlined
    #
    # @example Using nil to preserve values
    #   styled = Style.new(foreground: :red, bold: true)
    #   partial = Style.new(foreground: nil, italic: true)  # nil preserves red
    #   result = styled >> partial  # => foreground: :red, bold: true, italic: true
    #
    # @example Using :reset to clear styles
    #   styled = Style.new(foreground: :red, bold: true)
    #   reset = Style.new(foreground: :reset, bold: :reset)
    #   result = styled >> reset  # => foreground: nil, bold: nil
    #
    # @example Bold/faint mutual exclusion
    #   bold_style = Style.new(bold: true)
    #   faint_style = Style.new(faint: true)
    #   result1 = bold_style >> faint_style  # => faint wins (right-hand takes precedence)
    #   result2 = faint_style >> bold_style  # => bold wins (right-hand takes precedence)
    def >>(other)
      # Handle bold/faint mutual exclusion in composition
      composed_bold = compose_attribute(bold, other.bold)
      composed_faint = compose_attribute(faint, other.faint)

      # If other explicitly sets bold, clear faint; if other explicitly sets faint, clear bold
      if other.bold == true
        composed_faint = false
      elsif other.faint == true
        composed_bold = false
      elsif other.bold == :reset
        composed_bold = nil
      elsif other.faint == :reset
        composed_faint = nil
      end

      Style.new(
        foreground: compose_attribute(foreground, other.foreground),
        background: compose_attribute(background, other.background),
        inverse: compose_attribute(inverse, other.inverse),
        bold: composed_bold,
        faint: composed_faint,
        underline: compose_attribute(underline, other.underline),
        overline: compose_attribute(overline, other.overline),
        blink: compose_attribute(blink, other.blink),
        italic: compose_attribute(italic, other.italic),
        hide: compose_attribute(hide, other.hide)
      )
    end

    private def compose_attribute(current, other)
      if other.nil?
        current
      elsif other == :reset
        nil
      else
        other
      end
    end

    private def build_styles
      styles = []

      # Add colors individually
      if foreground && foreground != :default && background && background != :default
        styles << foreground
        styles << background
      elsif foreground && foreground != :default
        styles << foreground
      elsif background && background != :default
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
