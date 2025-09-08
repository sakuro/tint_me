#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark/ips"
require "benchmark/memory"
require "bundler/setup"
require "tint_me"

# Test data
SHORT_TEXT = "Hello"
MEDIUM_TEXT = "The quick brown fox jumps over the lazy dog"
LONG_TEXT = "Lorem ipsum dolor sit amet, " * 10

# Create various styles
SIMPLE_STYLE = TIntMe::Style.new(foreground: :red)
COMPLEX_STYLE = TIntMe::Style.new(
  foreground: :blue,
  background: :yellow,
  bold: true,
  italic: true,
  underline: true
)
HEX_STYLE = TIntMe::Style.new(
  foreground: "#FF6B35",
  background: "#F7931E",
  bold: true,
  overline: true
)

puts "=" * 60
puts "TIntMe Style Performance Benchmark"
puts "=" * 60
puts

# Memory benchmark
puts "Memory Usage Analysis:"
puts "-" * 40
Benchmark.memory do |x|
  x.report("Create simple style") do
    TIntMe::Style.new(foreground: :red)
  end

  x.report("Create complex style") do
    TIntMe::Style.new(
      foreground: :blue,
      background: :yellow,
      bold: true,
      italic: true,
      underline: true,
      overline: true,
      blink: true
    )
  end

  x.report("Apply simple style (short text)") do
    SIMPLE_STYLE.call(SHORT_TEXT)
  end

  x.report("Apply complex style (short text)") do
    COMPLEX_STYLE.call(SHORT_TEXT)
  end

  x.compare!
end

puts
puts "Performance Benchmark (operations per second):"
puts "-" * 40

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  # Style creation benchmarks
  x.report("Create simple style") do
    TIntMe::Style.new(foreground: :red)
  end

  x.report("Create complex style") do
    TIntMe::Style.new(
      foreground: :blue,
      background: :yellow,
      bold: true,
      italic: true,
      underline: true
    )
  end

  # Style application benchmarks
  x.report("Apply simple style (short)") do
    SIMPLE_STYLE.call(SHORT_TEXT)
  end

  x.report("Apply simple style (medium)") do
    SIMPLE_STYLE.call(MEDIUM_TEXT)
  end

  x.report("Apply simple style (long)") do
    SIMPLE_STYLE.call(LONG_TEXT)
  end

  x.report("Apply complex style (short)") do
    COMPLEX_STYLE.call(SHORT_TEXT)
  end

  x.report("Apply complex style (medium)") do
    COMPLEX_STYLE.call(MEDIUM_TEXT)
  end

  x.report("Apply complex style (long)") do
    COMPLEX_STYLE.call(LONG_TEXT)
  end

  x.report("Apply hex style (short)") do
    HEX_STYLE.call(SHORT_TEXT)
  end

  x.compare!
end

# Repeated application benchmark
puts
puts "Repeated Application Benchmark:"
puts "-" * 40
puts "Applying the same style 1000 times to measure caching benefit..."

styles = [SIMPLE_STYLE, COMPLEX_STYLE, HEX_STYLE]
style_names = %w[simple complex hex]

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  styles.zip(style_names).each do |style, name|
    x.report("1000x #{name} style") do
      1000.times { style.call(SHORT_TEXT) }
    end
  end

  x.compare!
end

# Object allocation tracking
puts
puts "Object Allocation Analysis:"
puts "-" * 40

# Counts object allocations during block execution
# @return [Integer] Number of objects allocated
def count_allocations
  before = GC.stat[:total_allocated_objects]
  yield
  after = GC.stat[:total_allocated_objects]
  after - before
end

# Measure allocations for different operations
operations = {
  "Create simple style" => -> { TIntMe::Style.new(foreground: :red) },
  "Create complex style" => -> {
    TIntMe::Style.new(
      foreground: :blue,
      background: :yellow,
      bold: true,
      italic: true,
      underline: true
    )
  },
  "Apply simple style 100x" => -> { 100.times { SIMPLE_STYLE.call(SHORT_TEXT) } },
  "Apply complex style 100x" => -> { 100.times { COMPLEX_STYLE.call(SHORT_TEXT) } }
}

operations.each do |name, operation|
  GC.start
  allocations = count_allocations(&operation)
  puts "#{name}: #{allocations} objects allocated"
end

puts
puts "=" * 60
puts "Benchmark complete!"
puts "=" * 60
