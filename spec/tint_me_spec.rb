# frozen_string_literal: true

require "spec_helper"

RSpec.describe TIntMe do
  it "has a version number" do
    expect(TIntMe::VERSION).not_to be_nil
  end

  describe ".[]" do
    it "creates a Style instance with given options" do
      style = TIntMe[foreground: :blue]
      expect(style).to be_a(TIntMe::Style)
      expect(style.foreground).to eq(:blue)
    end

    it "passes all options to Style.new" do
      style = TIntMe[foreground: :red, bold: true, underline: true]
      expect(style.foreground).to eq(:red)
      expect(style.bold).to be(true)
      expect(style.underline).to be(true)
    end

    it "works with no arguments" do
      style = TIntMe[]
      expect(style).to be_a(TIntMe::Style)
      expect(style.foreground).to be_nil
    end

    it "applies styling to text" do
      blue_style = TIntMe[foreground: :blue]
      expect(blue_style.call("test")).to eq(Paint["test", :blue])
    end

    it "supports style composition" do
      base = TIntMe[foreground: :red]
      emphasis = TIntMe[bold: true]
      combined = base >> emphasis
      expect(combined.call("test")).to eq(Paint["test", :red, :bold])
    end
  end
end
