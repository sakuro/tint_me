# :lipstick: TIntMe! :nail_care:

[![Gem Version](https://badge.fury.io/rb/tint_me.svg)](https://badge.fury.io/rb/tint_me)
[![CI](https://github.com/sakuro/tint_me/workflows/CI/badge.svg)](https://github.com/sakuro/tint_me/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Gem Downloads](https://img.shields.io/gem/dt/tint_me.svg)](https://rubygems.org/gems/tint_me)
[![Depfu](https://badges.depfu.com/badges/aec4d0a2094c04935f1db813351e5f56/overview.svg)](https://depfu.com/github/sakuro/tint_me)

A Ruby library for terminal text styling with ANSI colors and effects. TIntMe! provides an elegant and composable API for applying colors, text decorations, and formatting to terminal output.

## Features

- **Rich Color Support**: Foreground and background colors with support for standard colors and hex values
- **Text Effects**: Bold, faint, italic, underline (including double), overline, blink, inverse, and concealed text
- **Style Composition**: Combine multiple styles using the `>>` operator for layered styling
- **Type Safety**: Comprehensive argument validation using dry-schema and dry-types
- **Immutable Design**: All style operations return new instances, making them safe for concurrent use
- **Zeitwerk Integration**: Automatic loading with proper module organization
- **Comprehensive API**: Both explicit `Style.new` and convenient `TIntMe[]` shortcut syntax

## Installation

Add this line to your application's Gemfile:

```ruby
gem "tint_me"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install tint_me
```

## Usage

### Basic Styling

```ruby
require 'tint_me'

# Create a style
red_style = TIntMe::Style.new(foreground: :red)
puts red_style.call("Hello World")

# Using the shortcut syntax
blue_style = TIntMe[foreground: :blue, bold: true]
puts blue_style["Hello World"]
```

### Color Options

```ruby
# Standard colors
TIntMe[foreground: :red]
TIntMe[background: :yellow]

# Hex colors (with or without #)
TIntMe[foreground: "#FF0000"]
TIntMe[background: "#00FF00"]
TIntMe[foreground: "FF0000"]
```

### Text Effects

```ruby
# Individual effects
TIntMe[bold: true]
TIntMe[faint: true]          # Faint/dim text
TIntMe[italic: true]
TIntMe[underline: true]
TIntMe[underline: :double]   # Double underline
TIntMe[overline: true]       # Overline decoration
TIntMe[blink: true]          # Blinking text
TIntMe[inverse: true]        # Reverse colors
TIntMe[conceal: true]        # Hidden/concealed text

# Multiple effects
TIntMe[foreground: :green, bold: true, underline: true]
```

### Style Composition

```ruby
# Base styling
base = TIntMe[foreground: :blue]
emphasis = TIntMe[bold: true, underline: true]

# Combine styles (right-hand style takes precedence)
combined = base >> emphasis
puts combined.call("Styled text")

# Chain multiple compositions
final = base >> emphasis >> TIntMe[background: :white]
```

#### ⚡ Performance Considerations

**TIntMe is optimized for reusable styles** through SGR sequence pre-computation. The composition operator (`>>`) should be used thoughtfully:

```ruby
# ✅ RECOMMENDED: Pre-compose and reuse
ERROR_STYLE = TIntMe[foreground: :red] >> TIntMe[bold: true]
ERROR_STYLE.call("Error message")  # Fast: ~4.8M operations/sec

# ❌ AVOID: Runtime composition  
(TIntMe[foreground: :red] >> TIntMe[bold: true]).call("Error")  # Slow: ~0.01M ops/sec
```

**Key Guidelines:**
- **Use `>>` for initialization**: Create composed styles once and reuse them
- **Avoid runtime composition**: Don't chain `>>` operators inside loops or frequently-called methods
- **For one-time styling**: Consider alternatives like `Paint` gem for better dynamic performance
- **Each `>>` operation**: Creates new Style instances and recalculates SGR sequences

**Performance Comparison:**
- Pre-computed styles: **~4.8M operations/sec** (fastest)
- Runtime composition: **~0.01M operations/sec** (246x slower)
- Direct Style.new: **~0.03M operations/sec** (71x slower)

#### 🎯 When to Use TIntMe vs Alternatives

**TIntMe excels at:**
```ruby
# Terminal UI frameworks with predefined styles
UI_STYLES = {
  error:   TIntMe[foreground: :red] >> TIntMe[bold: true],
  success: TIntMe[foreground: :green] >> TIntMe[bold: true],
  info:    TIntMe[foreground: :blue] >> TIntMe[italic: true]
}

def show_error(msg)
  puts UI_STYLES[:error].call(msg)  # Extremely fast: ~4.8M ops/sec
end
```

**Consider alternatives for:**
```ruby
# Dynamic styling (use Paint gem instead)
texts.each { |text| Paint[text, :red, :bold] }  # ~2M ops/sec

# One-time styling with readable syntax (use Rainbow gem)
puts Rainbow("Success").green.bold  # ~0.5M ops/sec

# Avoid with TIntMe - creates unnecessary overhead
texts.each { |text| (red >> bold).call(text) }  # Only ~0.01M ops/sec
```

**Design Philosophy:**
TIntMe is intentionally optimized for the **"define once, use many"** pattern through SGR sequence pre-computation at initialization time. The performance characteristics guide you toward the most efficient usage patterns, where a small set of predefined styles serves many styling operations.

### Method Aliases

```ruby
style = TIntMe[foreground: :red, bold: true]

# All of these are equivalent
puts style.call("Hello")
puts style["Hello"]
puts style.("Hello")  # Callable syntax
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sakuro/tint_me.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
