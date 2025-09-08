# frozen_string_literal: true

require "paint"
require "spec_helper"

RSpec.describe TIntMe::Style do
  describe "#initialize" do
    it "creates a Style with default values" do
      style = TIntMe::Style.new
      expect(style.call("test")).to eq("test")
    end

    it "accepts foreground color" do
      style = TIntMe::Style.new(foreground: :red)
      expect(style.call("test")).to eq(Paint["test", :red])
    end

    it "accepts background color" do
      style = TIntMe::Style.new(background: :blue)
      expect(style.call("test")).to eq(Paint["test", nil, :blue])
    end

    it "accepts underline options" do
      style_true = TIntMe::Style.new(underline: true)
      expect(style_true.call("test")).to eq(Paint["test", :underline])

      style_double = TIntMe::Style.new(underline: :double)
      expect(style_double.call("test")).to eq(Paint["test", :double_underline])

      style_false = TIntMe::Style.new(underline: false)
      expect(style_false.call("test")).to eq("test")

      style_nil = TIntMe::Style.new(underline: nil)
      expect(style_nil.call("test")).to eq("test")
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
      expect(style_bold.call("test")).to eq(Paint["test", :bold])

      style_faint = TIntMe::Style.new(faint: true)
      expect(style_faint.call("test")).to eq(Paint["test", :faint])

      # Test explicit false
      style_bold_false = TIntMe::Style.new(bold: false)
      expect(style_bold_false.call("test")).to eq("test")
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
        hide: true
      )
      expected_styles = %i[green yellow underline overline bold blink italic inverse hide]
      expect(style.call("test")).to eq(Paint["test", *expected_styles])
    end
  end

  describe "#call" do
    it "returns plain text when no styles are applied" do
      style = TIntMe::Style.new
      expect(style.call("hello")).to eq("hello")
    end

    it "applies foreground color" do
      style = TIntMe::Style.new(foreground: :red)
      expect(style.call("hello")).to eq(Paint["hello", :red])
    end

    it "applies background color" do
      style = TIntMe::Style.new(background: :blue)
      expect(style.call("hello")).to eq(Paint["hello", nil, :blue])
    end

    it "applies multiple styles" do
      style = TIntMe::Style.new(foreground: :red, bold: true, underline: true)
      expect(style.call("hello")).to eq(Paint["hello", :red, :underline, :bold])
    end

    it "supports hex colors" do
      style = TIntMe::Style.new(foreground: "#FF0000")
      expect(style.call("hello")).to eq(Paint["hello", "#FF0000"])
    end

    it "supports RGB colors without hash" do
      style = TIntMe::Style.new(foreground: "FF0000")
      expect(style.call("hello")).to eq(Paint["hello", "FF0000"])
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
      expect(composed.call("hello")).to eq(Paint["hello", :blue, :white, :bold])
    end

    it "preserves left-hand attributes when right-hand has defaults" do
      style1 = TIntMe::Style.new(foreground: :red, bold: true)
      style2 = TIntMe::Style.new(background: :blue)

      composed = style1 >> style2
      expect(composed.call("hello")).to eq(Paint["hello", :red, :blue, :bold])
    end

    it "handles underline composition correctly" do
      style1 = TIntMe::Style.new(underline: true)
      style2 = TIntMe::Style.new(underline: :double)

      composed = style1 >> style2
      # Debug check - what is actually happening
      expect(composed.underline).to eq(:double)
      expect(composed.call("hello")).to eq(Paint["hello", :double_underline])
    end

    it "can chain multiple compositions" do
      style1 = TIntMe::Style.new(foreground: :red)
      style2 = TIntMe::Style.new(bold: true)
      style3 = TIntMe::Style.new(underline: true)

      composed = style1 >> style2 >> style3
      expect(composed.call("hello")).to eq(Paint["hello", :red, :underline, :bold])
    end

    it "handles bold/faint composition correctly" do
      # bold style composed with faint should result in faint (other wins)
      bold_style = TIntMe::Style.new(bold: true)
      faint_style = TIntMe::Style.new(faint: true)

      composed1 = bold_style >> faint_style
      expect(composed1.call("test")).to eq(Paint["test", :faint])

      # faint style composed with bold should result in bold (other wins)
      composed2 = faint_style >> bold_style
      expect(composed2.call("test")).to eq(Paint["test", :bold])

      # bold style composed with non-bold/non-faint should keep bold
      normal_style = TIntMe::Style.new(foreground: :red)
      composed3 = bold_style >> normal_style
      expect(composed3.call("test")).to eq(Paint["test", :red, :bold])
    end

    it "handles nil composition correctly" do
      # nil preserves left side values
      bold_style = TIntMe::Style.new(bold: true, inverse: true)
      normal_style = TIntMe::Style.new(foreground: :red) # all boolean attrs are nil

      composed = bold_style >> normal_style
      expect(composed.call("test")).to eq(Paint["test", :red, :bold, :inverse])

      # explicit false overrides left side
      inverse_style = TIntMe::Style.new(inverse: true)
      false_style = TIntMe::Style.new(inverse: false, foreground: :blue)

      composed2 = inverse_style >> false_style
      expect(composed2.call("test")).to eq(Paint["test", :blue]) # no inverse
    end
  end

  describe "Paint gem color compatibility" do
    it "supports basic color names" do
      colors = %i[red green blue cyan yellow magenta gray white black]
      colors.each do |color|
        style = TIntMe::Style.new(foreground: color)
        expect(style.call("test")).to eq(Paint["test", color])
      end
    end

    it "supports default color" do
      style = TIntMe::Style.new(foreground: :default)
      expect(style.call("test")).to eq("test")
    end
  end

  describe "text effects" do
    it "supports all boolean effects" do
      effects = {
        bold: :bold,
        faint: :faint,
        italic: :italic,
        inverse: :inverse,
        blink: :blink,
        overline: :overline,
        hide: :hide
      }

      effects.each do |param, paint_effect|
        style = TIntMe::Style.new(param => true)
        expect(style.call("test")).to eq(Paint["test", paint_effect])
      end
    end

    it "handles nil, false, and true states correctly" do
      # nil (default) - no effect
      style_nil = TIntMe::Style.new
      expect(style_nil.call("test")).to eq("test")

      # explicit false - no effect
      style_false = TIntMe::Style.new(bold: false, italic: false)
      expect(style_false.call("test")).to eq("test")

      # explicit true - applies effect
      style_true = TIntMe::Style.new(bold: true)
      expect(style_true.call("test")).to eq(Paint["test", :bold])
    end
  end
end
