# frozen_string_literal: true

RSpec.describe TIntMe::Style do
  # ANSI escape sequence for readability in test expectations
  let(:esc) { "\e" }

  describe "#initialize" do
    it "creates a Style with default values" do
      style = TIntMe::Style.new
      expect(style.call("TEST")).to eq("TEST")
    end

    it "accepts foreground color" do
      style = TIntMe::Style.new(foreground: :red)
      expect(style.call("TEST")).to eq("#{esc}[31mTEST#{esc}[0m")
    end

    it "accepts background color" do
      style = TIntMe::Style.new(background: :blue)
      expect(style.call("TEST")).to eq("#{esc}[44mTEST#{esc}[0m")
    end

    it "accepts underline options" do
      style_true = TIntMe::Style.new(underline: true)
      expect(style_true.call("TEST")).to eq("#{esc}[4mTEST#{esc}[0m")

      style_double = TIntMe::Style.new(underline: :double)
      expect(style_double.call("TEST")).to eq("#{esc}[21mTEST#{esc}[0m")

      style_false = TIntMe::Style.new(underline: false)
      expect(style_false.call("TEST")).to eq("TEST")

      style_nil = TIntMe::Style.new(underline: nil)
      expect(style_nil.call("TEST")).to eq("TEST")
    end

    it "rejects invalid underline values" do
      expect { TIntMe::Style.new(underline: :invalid) }.to raise_error(ArgumentError, /underline/)
    end

    it "rejects invalid color types" do
      expect { TIntMe::Style.new(foreground: 123) }.to raise_error(ArgumentError, /foreground/)
    end

    it "rejects invalid color names" do
      expect { TIntMe::Style.new(foreground: :orange) }.to raise_error(ArgumentError, /foreground/)
    end

    it "rejects invalid hex colors" do
      expect { TIntMe::Style.new(foreground: "#GGG") }.to raise_error(ArgumentError, /foreground/)
      expect { TIntMe::Style.new(foreground: "#12") }.to raise_error(ArgumentError, /foreground/)
      expect { TIntMe::Style.new(foreground: "#1234567") }.to raise_error(ArgumentError, /foreground/)
    end

    it "accepts valid hex colors" do
      expect { TIntMe::Style.new(foreground: "#123") }.not_to raise_error
      expect { TIntMe::Style.new(foreground: "#123456") }.not_to raise_error
      expect { TIntMe::Style.new(foreground: "123") }.not_to raise_error
      expect { TIntMe::Style.new(foreground: "123456") }.not_to raise_error
    end

    it "rejects invalid boolean types" do
      expect { TIntMe::Style.new(bold: "true") }.to raise_error(ArgumentError, /bold/)
    end

    it "handles bold and faint mutual exclusion" do
      expect { TIntMe::Style.new(bold: true, faint: true) }.to raise_error(ArgumentError, "Cannot specify both bold and faint simultaneously")

      style_bold = TIntMe::Style.new(bold: true)
      expect(style_bold.call("TEST")).to eq("#{esc}[1mTEST#{esc}[0m")

      style_faint = TIntMe::Style.new(faint: true)
      expect(style_faint.call("TEST")).to eq("#{esc}[2mTEST#{esc}[0m")

      # Test explicit false
      style_bold_false = TIntMe::Style.new(bold: false)
      expect(style_bold_false.call("TEST")).to eq("TEST")
    end

    it "accepts all style options" do
      style = TIntMe::Style.new(
        foreground: :green,
        background: :yellow,
        bold: true,
        underline: true,
        overline: true,
        blink: true,
        italic: true,
        inverse: true,
        conceal: true
      )
      # Multiple styles: green (32), yellow bg (43), bold (1), italic (3), underline (4),
      # blink (5), inverse (7), conceal (8), overline (53)
      expect(style.call("TEST")).to eq("#{esc}[32;43;1;3;4;5;7;8;53mTEST#{esc}[0m")
    end
  end

  describe "#call" do
    it "returns plain text when no styles are applied" do
      style = TIntMe::Style.new
      expect(style.call("hello")).to eq("hello")
    end

    it "applies foreground color" do
      style = TIntMe::Style.new(foreground: :red)
      expect(style.call("hello")).to eq("#{esc}[31mhello#{esc}[0m")
    end

    it "applies background color" do
      style = TIntMe::Style.new(background: :blue)
      expect(style.call("hello")).to eq("#{esc}[44mhello#{esc}[0m")
    end

    it "applies multiple styles" do
      style = TIntMe::Style.new(foreground: :red, bold: true, underline: true)
      expect(style.call("hello")).to eq("#{esc}[31;1;4mhello#{esc}[0m")
    end

    it "supports hex colors" do
      style = TIntMe::Style.new(foreground: "#FF0000")
      expect(style.call("hello")).to eq("#{esc}[38;2;255;0;0mhello#{esc}[0m")
    end

    it "supports RGB colors without hash" do
      style = TIntMe::Style.new(foreground: "FF0000")
      expect(style.call("hello")).to eq("#{esc}[38;2;255;0;0mhello#{esc}[0m")
    end
  end

  describe "#[]" do
    it "is an alias for #call" do
      style = TIntMe::Style.new(foreground: :red)
      expect(style["hello"]).to eq(style.call("hello"))
    end
  end

  describe "#>>" do
    it "composes two styles with right-hand precedence" do
      style1 = TIntMe::Style.new(foreground: :red, background: :white, underline: true)
      style2 = TIntMe::Style.new(foreground: :blue, bold: true, underline: false)

      composed = style1 >> style2
      expect(composed.call("hello")).to eq("#{esc}[34;47;1mhello#{esc}[0m")
    end

    it "preserves left-hand attributes when right-hand has defaults" do
      style1 = TIntMe::Style.new(foreground: :red, bold: true)
      style2 = TIntMe::Style.new(background: :blue)

      composed = style1 >> style2
      expect(composed.call("hello")).to eq("#{esc}[31;44;1mhello#{esc}[0m")
    end

    it "handles underline composition correctly" do
      style1 = TIntMe::Style.new(underline: true)
      style2 = TIntMe::Style.new(underline: :double)

      composed = style1 >> style2
      # Debug check - what is actually happening
      expect(composed.underline).to eq(:double)
      expect(composed.call("hello")).to eq("#{esc}[21mhello#{esc}[0m")
    end

    it "can chain multiple compositions" do
      style1 = TIntMe::Style.new(foreground: :red)
      style2 = TIntMe::Style.new(bold: true)
      style3 = TIntMe::Style.new(underline: true)

      composed = style1 >> style2 >> style3
      expect(composed.call("hello")).to eq("#{esc}[31;1;4mhello#{esc}[0m")
    end

    it "handles bold/faint composition correctly" do
      # bold style composed with faint should result in faint (other wins)
      bold_style = TIntMe::Style.new(bold: true)
      faint_style = TIntMe::Style.new(faint: true)

      composed1 = bold_style >> faint_style
      expect(composed1.call("TEST")).to eq("#{esc}[2mTEST#{esc}[0m")

      # faint style composed with bold should result in bold (other wins)
      composed2 = faint_style >> bold_style
      expect(composed2.call("TEST")).to eq("#{esc}[1mTEST#{esc}[0m")

      # bold style composed with non-bold/non-faint should keep bold
      normal_style = TIntMe::Style.new(foreground: :red)
      composed3 = bold_style >> normal_style
      expect(composed3.call("TEST")).to eq("#{esc}[31;1mTEST#{esc}[0m")
    end

    it "handles nil composition correctly" do
      # nil preserves left side values
      bold_style = TIntMe::Style.new(bold: true, inverse: true)
      normal_style = TIntMe::Style.new(foreground: :red) # all boolean attrs are nil

      composed = bold_style >> normal_style
      expect(composed.call("TEST")).to eq("#{esc}[31;1;7mTEST#{esc}[0m")

      # explicit false overrides left side
      inverse_style = TIntMe::Style.new(inverse: true)
      false_style = TIntMe::Style.new(inverse: false, foreground: :blue)

      composed2 = inverse_style >> false_style
      expect(composed2.call("TEST")).to eq("#{esc}[34mTEST#{esc}[0m") # no inverse
    end
  end

  describe "color support" do
    it "supports basic color names" do
      expect(TIntMe::Style.new(foreground: :red).call("TEST")).to eq("#{esc}[31mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :green).call("TEST")).to eq("#{esc}[32mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :blue).call("TEST")).to eq("#{esc}[34mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :cyan).call("TEST")).to eq("#{esc}[36mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :yellow).call("TEST")).to eq("#{esc}[33mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :magenta).call("TEST")).to eq("#{esc}[35mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :gray).call("TEST")).to eq("#{esc}[90mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :white).call("TEST")).to eq("#{esc}[37mTEST#{esc}[0m")
      expect(TIntMe::Style.new(foreground: :black).call("TEST")).to eq("#{esc}[30mTEST#{esc}[0m")
    end

    it "supports default color" do
      style = TIntMe::Style.new(foreground: :default)
      expect(style.call("TEST")).to eq("TEST")
    end
  end

  describe "text effects" do
    it "supports all boolean effects" do
      effects = {
        bold: 1,
        faint: 2,
        italic: 3,
        inverse: 7,
        blink: 5,
        overline: 53,
        conceal: 8
      }

      effects.each do |param, code|
        style = TIntMe::Style.new(param => true)
        expect(style.call("TEST")).to eq("#{esc}[#{code}mTEST#{esc}[0m")
      end
    end

    it "handles nil, false, and true states correctly" do
      # nil (default) - no effect
      style_nil = TIntMe::Style.new
      expect(style_nil.call("TEST")).to eq("TEST")

      # explicit false - no effect
      style_false = TIntMe::Style.new(bold: false, italic: false)
      expect(style_false.call("TEST")).to eq("TEST")

      # explicit true - applies effect
      style_true = TIntMe::Style.new(bold: true)
      expect(style_true.call("TEST")).to eq("#{esc}[1mTEST#{esc}[0m")
    end
  end

  describe "positional arguments" do
    describe ".new" do
      context "with boolean flags as positional arguments" do
        it "accepts single boolean flag" do
          style = TIntMe::Style.new(:bold)
          expect(style.bold).to be true
          expect(style.italic).to be_nil
        end

        it "accepts multiple boolean flags" do
          style = TIntMe::Style.new(:bold, :italic, :underline)
          expect(style.bold).to be true
          expect(style.italic).to be true
          expect(style.underline).to be true
        end

        it "handles duplicate boolean flags idempotently" do
          style = TIntMe::Style.new(:bold, :italic, :bold)
          expect(style.bold).to be true
          expect(style.italic).to be true
        end
      end

      context "with color names as positional arguments" do
        it "accepts color symbol as foreground" do
          style = TIntMe::Style.new(:red)
          expect(style.foreground).to eq :red
        end

        it "accepts bright color symbol" do
          style = TIntMe::Style.new(:bright_blue)
          expect(style.foreground).to eq :bright_blue
        end

        it "last color wins when multiple colors specified" do
          style = TIntMe::Style.new(:red, :blue, :green)
          expect(style.foreground).to eq :green
        end
      end

      context "with hex colors as positional arguments" do
        it "accepts 6-digit hex color with hash" do
          style = TIntMe::Style.new("#FF0000", :bold)
          expect(style.foreground).to eq "#FF0000"
          expect(style.bold).to be true
        end

        it "accepts 6-digit hex color without hash" do
          style = TIntMe::Style.new("FF0000", :italic)
          expect(style.foreground).to eq "FF0000"
          expect(style.italic).to be true
        end

        it "accepts 3-digit hex color" do
          style = TIntMe::Style.new("#F00", :underline)
          expect(style.foreground).to eq "#F00"
          expect(style.underline).to be true
        end

        it "last hex color wins when multiple specified" do
          style = TIntMe::Style.new("#FF0000", "#00FF00", "#0000FF")
          expect(style.foreground).to eq "#0000FF"
        end
      end

      context "with mixed positional and keyword arguments" do
        it "accepts color and flags as positional with background as keyword" do
          style = TIntMe::Style.new(:red, :bold, background: :yellow)
          expect(style.foreground).to eq :red
          expect(style.bold).to be true
          expect(style.background).to eq :yellow
        end

        it "keyword arguments override positional colors" do
          style = TIntMe::Style.new(:red, :blue, foreground: :green)
          expect(style.foreground).to eq :green
        end

        it "keyword arguments override positional boolean flags" do
          style = TIntMe::Style.new(:bold, :italic, bold: false)
          expect(style.bold).to be false
          expect(style.italic).to be true
        end

        it "accepts hex color with boolean flags and keyword arguments" do
          style = TIntMe::Style.new("#FF0000", :bold, :italic, background: "#0000FF")
          expect(style.foreground).to eq "#FF0000"
          expect(style.background).to eq "#0000FF"
          expect(style.bold).to be true
          expect(style.italic).to be true
        end
      end

      context "with invalid positional arguments" do
        it "raises ArgumentError for unknown symbol" do
          expect { TIntMe::Style.new(:invalid_flag) }.to raise_error(ArgumentError, /Invalid positional argument/)
        end

        it "raises ArgumentError for non-symbol/non-string argument" do
          expect { TIntMe::Style.new(123) }.to raise_error(ArgumentError, /Invalid positional argument/)
        end

        it "raises ArgumentError for invalid hex string" do
          expect { TIntMe::Style.new("#GGGGGG") }.to raise_error(ArgumentError, /Invalid positional argument/)
        end
      end

      context "with backward compatibility" do
        it "works with only keyword arguments" do
          style = TIntMe::Style.new(foreground: :red, bold: true, italic: false)
          expect(style.foreground).to eq :red
          expect(style.bold).to be true
          expect(style.italic).to be false
        end

        it "works with no arguments" do
          style = TIntMe::Style.new
          expect(style.foreground).to be_nil
          expect(style.bold).to be_nil
        end
      end
    end

    describe ".[]" do
      it "supports positional arguments like .new" do
        style = TIntMe::Style[:red, :bold, :italic]
        expect(style.foreground).to eq :red
        expect(style.bold).to be true
        expect(style.italic).to be true
      end

      it "supports mixed positional and keyword arguments" do
        style = TIntMe::Style[:red, :bold, background: :blue]
        expect(style.foreground).to eq :red
        expect(style.bold).to be true
        expect(style.background).to eq :blue
      end

      it "keyword arguments override positional arguments" do
        style = TIntMe::Style[:red, foreground: :blue, bold: false]
        expect(style.foreground).to eq :blue
        expect(style.bold).to be false
      end
    end
  end
end
