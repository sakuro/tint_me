# frozen_string_literal: true

RSpec.describe TIntMe::SGRBuilder do
  # ANSI escape sequence for readability in test expectations
  let(:esc) { "\e" }
  let(:builder) { TIntMe::SGRBuilder.instance }

  describe "#prefix_codes" do
    context "with no styles" do
      it "returns empty string" do
        expect(builder.prefix_codes).to eq("")
      end
    end

    context "with foreground colors" do
      it "generates correct SGR for standard colors" do
        expect(builder.prefix_codes(foreground: :red)).to eq("#{esc}[31m")
        expect(builder.prefix_codes(foreground: :green)).to eq("#{esc}[32m")
        expect(builder.prefix_codes(foreground: :blue)).to eq("#{esc}[34m")
        expect(builder.prefix_codes(foreground: :yellow)).to eq("#{esc}[33m")
        expect(builder.prefix_codes(foreground: :magenta)).to eq("#{esc}[35m")
        expect(builder.prefix_codes(foreground: :cyan)).to eq("#{esc}[36m")
        expect(builder.prefix_codes(foreground: :white)).to eq("#{esc}[37m")
        expect(builder.prefix_codes(foreground: :black)).to eq("#{esc}[30m")
        expect(builder.prefix_codes(foreground: :gray)).to eq("#{esc}[90m")
      end

      it "generates correct SGR for bright colors" do
        expect(builder.prefix_codes(foreground: :bright_red)).to eq("#{esc}[91m")
        expect(builder.prefix_codes(foreground: :bright_green)).to eq("#{esc}[92m")
        expect(builder.prefix_codes(foreground: :bright_blue)).to eq("#{esc}[94m")
        expect(builder.prefix_codes(foreground: :bright_yellow)).to eq("#{esc}[93m")
        expect(builder.prefix_codes(foreground: :bright_magenta)).to eq("#{esc}[95m")
        expect(builder.prefix_codes(foreground: :bright_cyan)).to eq("#{esc}[96m")
        expect(builder.prefix_codes(foreground: :bright_white)).to eq("#{esc}[97m")
        expect(builder.prefix_codes(foreground: :bright_black)).to eq("#{esc}[90m")
      end

      it "handles hex colors" do
        # 6-digit hex with/without #
        expect(builder.prefix_codes(foreground: "#FF0000")).to eq("#{esc}[38;2;255;0;0m")  # Red
        expect(builder.prefix_codes(foreground: "FF0000")).to eq("#{esc}[38;2;255;0;0m")   # Red without #
        expect(builder.prefix_codes(foreground: "#00FF00")).to eq("#{esc}[38;2;0;255;0m")  # Green
        expect(builder.prefix_codes(foreground: "#0000FF")).to eq("#{esc}[38;2;0;0;255m")  # Blue
        expect(builder.prefix_codes(foreground: "#FFFFFF")).to eq("#{esc}[38;2;255;255;255m") # White
        expect(builder.prefix_codes(foreground: "#000000")).to eq("#{esc}[38;2;0;0;0m") # Black

        # 3-digit hex with/without #
        expect(builder.prefix_codes(foreground: "#F00")).to eq("#{esc}[38;2;255;0;0m")     # Red
        expect(builder.prefix_codes(foreground: "F00")).to eq("#{esc}[38;2;255;0;0m")      # Red without #
        expect(builder.prefix_codes(foreground: "#0F0")).to eq("#{esc}[38;2;0;255;0m")     # Green
        expect(builder.prefix_codes(foreground: "#00F")).to eq("#{esc}[38;2;0;0;255m")     # Blue
        expect(builder.prefix_codes(foreground: "#FFF")).to eq("#{esc}[38;2;255;255;255m") # White
        expect(builder.prefix_codes(foreground: "#000")).to eq("#{esc}[38;2;0;0;0m")       # Black

        # Mixed case
        expect(builder.prefix_codes(foreground: "#AbCdEf")).to eq("#{esc}[38;2;171;205;239m")
        expect(builder.prefix_codes(foreground: "abCDef")).to eq("#{esc}[38;2;171;205;239m")

        # Various values
        expect(builder.prefix_codes(foreground: "#7F8080")).to eq("#{esc}[38;2;127;128;128m")
        expect(builder.prefix_codes(foreground: "#FF6B35")).to eq("#{esc}[38;2;255;107;53m")
      end
    end

    context "with background colors" do
      it "generates correct SGR for background colors" do
        expect(builder.prefix_codes(background: :red)).to eq("#{esc}[41m")
        expect(builder.prefix_codes(background: :blue)).to eq("#{esc}[44m")
        expect(builder.prefix_codes(background: :green)).to eq("#{esc}[42m")
      end

      it "generates correct SGR for bright background colors" do
        expect(builder.prefix_codes(background: :bright_red)).to eq("#{esc}[101m")
        expect(builder.prefix_codes(background: :bright_blue)).to eq("#{esc}[104m")
        expect(builder.prefix_codes(background: :bright_green)).to eq("#{esc}[102m")
      end

      it "handles hex background colors" do
        # 6-digit hex with/without #
        expect(builder.prefix_codes(background: "#FF0000")).to eq("#{esc}[48;2;255;0;0m")  # Red
        expect(builder.prefix_codes(background: "00FF00")).to eq("#{esc}[48;2;0;255;0m")   # Green without #
        expect(builder.prefix_codes(background: "#0000FF")).to eq("#{esc}[48;2;0;0;255m")  # Blue
        expect(builder.prefix_codes(background: "#FFFFFF")).to eq("#{esc}[48;2;255;255;255m") # White
        expect(builder.prefix_codes(background: "#000000")).to eq("#{esc}[48;2;0;0;0m") # Black

        # 3-digit hex
        expect(builder.prefix_codes(background: "#F00")).to eq("#{esc}[48;2;255;0;0m")     # Red
        expect(builder.prefix_codes(background: "0F0")).to eq("#{esc}[48;2;0;255;0m")      # Green without #
        expect(builder.prefix_codes(background: "#00F")).to eq("#{esc}[48;2;0;0;255m")     # Blue

        # Mixed case and various values
        expect(builder.prefix_codes(background: "#AbCdEf")).to eq("#{esc}[48;2;171;205;239m")
        expect(builder.prefix_codes(background: "F7931E")).to eq("#{esc}[48;2;247;147;30m")  # Orange
        expect(builder.prefix_codes(background: "#2C3E50")).to eq("#{esc}[48;2;44;62;80m")   # Dark blue-gray
      end
    end

    context "with foreground and background" do
      it "combines both colors" do
        expect(builder.prefix_codes(foreground: :red, background: :blue)).to eq("#{esc}[31;44m")
        expect(builder.prefix_codes(foreground: :yellow, background: :magenta)).to eq("#{esc}[33;45m")
      end

      it "combines hex colors" do
        expect(builder.prefix_codes(foreground: "#FF0000", background: "#00FF00")).to eq("#{esc}[38;2;255;0;0;48;2;0;255;0m")
      end
    end

    context "with text effects" do
      it "generates correct SGR for effects" do
        expect(builder.prefix_codes(bold: true)).to eq("#{esc}[1m")
        expect(builder.prefix_codes(faint: true)).to eq("#{esc}[2m")
        expect(builder.prefix_codes(italic: true)).to eq("#{esc}[3m")
        expect(builder.prefix_codes(underline: true)).to eq("#{esc}[4m")
        expect(builder.prefix_codes(blink: true)).to eq("#{esc}[5m")
        expect(builder.prefix_codes(inverse: true)).to eq("#{esc}[7m")
        expect(builder.prefix_codes(conceal: true)).to eq("#{esc}[8m")
        expect(builder.prefix_codes(overline: true)).to eq("#{esc}[53m")
        expect(builder.prefix_codes(underline: :double)).to eq("#{esc}[21m")
      end
    end

    context "with multiple styles" do
      it "combines colors and effects" do
        expect(builder.prefix_codes(foreground: :red, bold: true)).to eq("#{esc}[31;1m")
        expect(builder.prefix_codes(foreground: :blue, background: :white, underline: true)).to eq("#{esc}[34;47;4m")
      end

      it "handles complex combinations" do
        expected = "#{esc}[32;43;1;3;4;5;7;8;53m"
        expect(
          builder.prefix_codes(
            foreground: :green,
            background: :yellow,
            underline: true,
            overline: true,
            bold: true,
            blink: true,
            italic: true,
            inverse: true,
            conceal: true
          )
        ).to eq(expected)
      end
    end

    context "with nil values" do
      it "skips nil values" do
        expect(builder.prefix_codes(background: :red, bold: true)).to eq("#{esc}[41;1m")
      end
    end

    context "with invalid values" do
      it "raises error for unknown foreground color" do
        expect { builder.prefix_codes(foreground: :unknown) }.to raise_error(ArgumentError, /Unknown foreground color: unknown/)
      end

      it "raises error for invalid foreground type" do
        expect { builder.prefix_codes(foreground: 123) }.to raise_error(ArgumentError, /Invalid foreground type/)
      end

      it "raises error for unknown background color" do
        expect { builder.prefix_codes(background: :unknown) }.to raise_error(ArgumentError, /Unknown background color: unknown/)
      end

      it "raises error for invalid background type" do
        expect { builder.prefix_codes(background: 123) }.to raise_error(ArgumentError, /Invalid background type/)
      end

      it "raises error for invalid underline value" do
        expect { builder.prefix_codes(underline: :unknown) }.to raise_error(ArgumentError, /Invalid underline value/)
      end

      it "raises error for invalid hex color" do
        expect { builder.prefix_codes(foreground: "#GGG") }.to raise_error(ArgumentError, /Invalid hex color/)
      end
    end
  end

  describe "#reset_code" do
    it "returns correct reset sequence" do
      expect(builder.reset_code).to eq("#{esc}[0m")
    end
  end

  describe "private methods" do
    describe "#hex_to_rgb" do
      it "converts 6-digit hex to RGB" do
        expect(builder.__send__(:hex_to_rgb, "#FF0000")).to eq([255, 0, 0])
        expect(builder.__send__(:hex_to_rgb, "00FF00")).to eq([0, 255, 0])
        expect(builder.__send__(:hex_to_rgb, "#0000FF")).to eq([0, 0, 255])
      end

      it "converts 3-digit hex to RGB" do
        expect(builder.__send__(:hex_to_rgb, "#F00")).to eq([255, 0, 0])
        expect(builder.__send__(:hex_to_rgb, "0F0")).to eq([0, 255, 0])
        expect(builder.__send__(:hex_to_rgb, "#00F")).to eq([0, 0, 255])
      end

      it "handles mixed case" do
        expect(builder.__send__(:hex_to_rgb, "#fF0000")).to eq([255, 0, 0])
        expect(builder.__send__(:hex_to_rgb, "A0B1C2")).to eq([160, 177, 194])
      end
    end

    describe "#hex_color?" do
      it "identifies valid hex colors" do
        expect(builder.__send__(:hex_color?, "#FF0000")).to be(true)
        expect(builder.__send__(:hex_color?, "FF0000")).to be(true)
        expect(builder.__send__(:hex_color?, "#F00")).to be(true)
        expect(builder.__send__(:hex_color?, "F00")).to be(true)
        expect(builder.__send__(:hex_color?, "#abcdef")).to be(true)
        expect(builder.__send__(:hex_color?, "123456")).to be(true)
      end

      it "rejects invalid hex colors" do
        expect(builder.__send__(:hex_color?, "#GG0000")).to be(false)
        expect(builder.__send__(:hex_color?, "#12")).to be(false)
        expect(builder.__send__(:hex_color?, "#1234567")).to be(false)
        expect(builder.__send__(:hex_color?, "red")).to be(false)
        expect(builder.__send__(:hex_color?, "")).to be(false)
      end
    end
  end

  describe "singleton pattern" do
    it "returns the same instance" do
      instance1 = TIntMe::SGRBuilder.instance
      instance2 = TIntMe::SGRBuilder.instance
      expect(instance1).to be(instance2)
    end

    it "makes new private" do
      expect { TIntMe::SGRBuilder.new }.to raise_error(NoMethodError, /private method/)
    end
  end

  describe "constants" do
    it "defines expected constants" do
      expect(described_class::ESC).to eq("\e")
      expect(described_class::CSI).to eq("\e[")
      expect(described_class::SGR_END).to eq("m")
      expect(described_class::RESET_CODE).to eq("\e[0m")
    end

    it "includes all expected colors" do
      colors = described_class::COLORS

      # Standard colors
      expect(colors[:red]).to eq(31)
      expect(colors[:green]).to eq(32)
      expect(colors[:blue]).to eq(34)
      expect(colors[:yellow]).to eq(33)
      expect(colors[:magenta]).to eq(35)
      expect(colors[:cyan]).to eq(36)
      expect(colors[:white]).to eq(37)
      expect(colors[:black]).to eq(30)
      expect(colors[:gray]).to eq(90)
      expect(colors[:default]).to eq(39)

      # Bright colors
      expect(colors[:bright_red]).to eq(91)
      expect(colors[:bright_green]).to eq(92)
      expect(colors[:bright_blue]).to eq(94)
      expect(colors[:bright_yellow]).to eq(93)
      expect(colors[:bright_magenta]).to eq(95)
      expect(colors[:bright_cyan]).to eq(96)
      expect(colors[:bright_white]).to eq(97)
      expect(colors[:bright_black]).to eq(90)
    end

    it "includes all expected effects" do
      effects = described_class::EFFECTS

      expect(effects[:bold]).to eq(1)
      expect(effects[:faint]).to eq(2)
      expect(effects[:italic]).to eq(3)
      expect(effects[:underline]).to eq(4)
      expect(effects[:blink]).to eq(5)
      expect(effects[:inverse]).to eq(7)
      expect(effects[:conceal]).to eq(8)
      expect(effects[:overline]).to eq(53)
      expect(effects[:double_underline]).to eq(21)
    end
  end
end
