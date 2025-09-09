# frozen_string_literal: true

module TIntMe
  # Builds ANSI SGR (Select Graphic Rendition) escape sequences for terminal styling
  #
  # This class is responsible for generating the correct ANSI escape sequences
  # for colors and text effects. It supports standard colors, bright colors,
  # RGB colors, and various text decorations.
  #
  # @api private
  class SGRBuilder
    # ANSI escape sequence components
    ESC = "\e"
    public_constant :ESC

    CSI = "#{ESC}[".freeze # Control Sequence Introducer
    public_constant :CSI

    SGR_END = "m"
    public_constant :SGR_END

    RESET_CODE = "#{CSI}0#{SGR_END}".freeze
    public_constant :RESET_CODE

    # Standard colors + bright colors
    COLORS = {
      black: 30,
      red: 31,
      green: 32,
      yellow: 33,
      blue: 34,
      magenta: 35,
      cyan: 36,
      white: 37,
      default: 39,
      gray: 90,
      # Bright colors (90-97)
      bright_black: 90,
      bright_red: 91,
      bright_green: 92,
      bright_yellow: 93,
      bright_blue: 94,
      bright_magenta: 95,
      bright_cyan: 96,
      bright_white: 97
    }.freeze
    public_constant :COLORS

    # Effects mapping (SGR parameters)
    EFFECTS = {
      bold: 1,
      faint: 2,
      italic: 3,
      underline: 4,
      blink: 5,
      inverse: 7,
      conceal: 8,
      overline: 53,
      double_underline: 21
    }.freeze
    public_constant :EFFECTS

    # Returns the singleton instance of SGRBuilder
    # @return [SGRBuilder] The singleton instance
    def self.instance
      @instance ||= new
    end

    # Make new private to enforce singleton pattern
    private_class_method :new

    # Generates SGR prefix codes for the given styles
    #
    # Parameters are processed in this order for predictable output:
    # 1. Foreground color (30-37, 90-97, or 38;2;r;g;b for RGB)
    # 2. Background color (40-47, 100-107, or 48;2;r;g;b for RGB)
    # 3. Text effects in numerical SGR code order:
    #    bold(1), faint(2), italic(3), underline(4), blink(5), inverse(7),
    #    conceal(8), double_underline(21), overline(53)
    #
    # @param foreground [Symbol, String, nil] Foreground color
    #   - Symbol: :red, :green, :blue, :yellow, :magenta, :cyan, :white, :black,
    #     :gray, :bright_red, :bright_green, etc.
    #   - String: Hex colors like "#FF0000", "FF0000", "#F00", "F00"
    # @param background [Symbol, String, nil] Background color (same format as foreground)
    # @param bold [Boolean, nil] Bold text effect
    # @param faint [Boolean, nil] Faint text effect
    # @param italic [Boolean, nil] Italic text effect
    # @param underline [Boolean, Symbol, nil] Underline effect (true, :double, or nil)
    # @param blink [Boolean, nil] Blink effect
    # @param inverse [Boolean, nil] Inverse/reverse effect
    # @param conceal [Boolean, nil] Conceal/hide effect
    # @param overline [Boolean, nil] Overline effect
    # @return [String] The SGR escape sequence string
    #
    # @example Standard colors
    #   prefix_codes(foreground: :red, bold: true)
    #   # => "\e[31;1m"
    #
    # @example RGB true color (24-bit)
    #   prefix_codes(foreground: "#FF6B35", background: "#F7931E")
    #   # => "\e[38;2;255;107;53;48;2;247;147;30m"
    #
    # @example Multiple effects with colors (colors first, then effects in numerical order)
    #   prefix_codes(foreground: :red, background: :blue, bold: true, italic: true)
    #   # => "\e[31;44;1;3m" (red=31, blue_bg=44, bold=1, italic=3)
    #
    # @example Double underline
    #   prefix_codes(foreground: :blue, underline: :double)
    #   # => "\e[34;21m"
    def prefix_codes(
      foreground: nil,
      background: nil,
      bold: nil,
      faint: nil,
      italic: nil,
      underline: nil,
      blink: nil,
      inverse: nil,
      conceal: nil,
      overline: nil
    )
      parameters = build_parameters(
        foreground:,
        background:,
        bold:,
        faint:,
        italic:,
        underline:,
        blink:,
        inverse:,
        conceal:,
        overline:
      )
      build_sgr_sequence(parameters)
    end

    # Returns the SGR reset code
    # @return [String] The reset escape sequence
    def reset_code
      RESET_CODE
    end

    # Converts RGB values to SGR parameters
    # @param red [Integer] Red component (0-255)
    # @param green [Integer] Green component (0-255)
    # @param blue [Integer] Blue component (0-255)
    # @param background [Boolean] Whether this is for background color
    # @return [String] The SGR parameter string for RGB color
    private def rgb_to_sgr(red, green, blue, background: false)
      base = background ? 48 : 38
      "#{base};2;#{red};#{green};#{blue}"
    end

    private def build_parameters(
      foreground:,
      background:,
      bold:,
      faint:,
      italic:,
      underline:,
      blink:,
      inverse:,
      conceal:,
      overline:
    )
      parameters = []

      # Process foreground color
      parameters << process_foreground_color(foreground) if foreground

      # Process background color
      parameters << process_background_color(background) if background

      # Collect effects and sort by SGR code for predictable order
      effects = []
      effects << EFFECTS[:bold] if bold == true
      effects << EFFECTS[:faint] if faint == true
      effects << EFFECTS[:italic] if italic == true
      case underline
      when true
        effects << EFFECTS[:underline]
      when :double
        effects << EFFECTS[:double_underline]
      when nil
        # No underline
      else
        raise ArgumentError, "Invalid underline value: #{underline.inspect}"
      end
      effects << EFFECTS[:blink] if blink == true
      effects << EFFECTS[:inverse] if inverse == true
      effects << EFFECTS[:conceal] if conceal == true
      effects << EFFECTS[:overline] if overline == true

      parameters.concat(effects.sort)
    end

    private def process_foreground_color(foreground)
      case foreground
      when String
        raise ArgumentError, "Invalid hex color: #{foreground}" unless hex_color?(foreground)

        red, green, blue = hex_to_rgb(foreground)
        rgb_to_sgr(red, green, blue, background: false)
      when Symbol
        raise ArgumentError, "Unknown foreground color: #{foreground}" unless COLORS.key?(foreground)

        COLORS[foreground]
      else
        raise ArgumentError, "Invalid foreground type: #{foreground.class}"
      end
    end

    private def process_background_color(background)
      case background
      when String
        raise ArgumentError, "Invalid hex color: #{background}" unless hex_color?(background)

        red, green, blue = hex_to_rgb(background)
        rgb_to_sgr(red, green, blue, background: true)
      when Symbol
        raise ArgumentError, "Unknown background color: #{background}" unless COLORS.key?(background)

        color_code = COLORS[background]
        # Convert to background color code
        color_code += 10 if color_code.between?(30, 37)
        color_code += 10 if color_code.between?(90, 97)
        color_code
      else
        raise ArgumentError, "Invalid background type: #{background.class}"
      end
    end

    private def build_sgr_sequence(parameters)
      return "" if parameters.empty?

      "#{CSI}#{parameters.join(";")}#{SGR_END}"
    end

    private def hex_color?(value)
      value.match?(/\A#?[0-9A-Fa-f]{3}([0-9A-Fa-f]{3})?\z/)
    end

    private def hex_to_rgb(hex)
      # Remove # if present
      hex = hex.delete_prefix("#")

      # Expand 3-digit hex to 6-digit
      hex = hex.chars.map {|c| c * 2 }.join if hex.length == 3

      # Convert to RGB values
      [
        hex[0..1].to_i(16),
        hex[2..3].to_i(16),
        hex[4..5].to_i(16)
      ]
    end
  end
end
