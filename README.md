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
- **Positional Arguments**: Concise syntax with `TIntMe[:red, :bold]` for streamlined styling

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

TIntMe supports both keyword arguments and positional arguments for creating styles. Here are examples using keyword arguments:

```ruby
require 'tint_me'

# Create a style with keyword arguments
red_style = TIntMe[foreground: :red]
puts red_style.call("Hello World")

# Using the shortcut syntax
blue_style = TIntMe[foreground: :blue, bold: true]
puts blue_style["Hello World"]
```

### Positional Arguments

TIntMe supports a concise positional argument syntax for common styling scenarios:

#### Supported Positional Arguments

**Colors** (applied as foreground):
- Color symbols: `:red`, `:green`, `:blue`, `:yellow`, `:magenta`, `:cyan`, `:white`, `:black`, `:gray`  
- Bright colors: `:bright_red`, `:bright_green`, `:bright_blue`, etc.
- Special values: `:default`, `:reset`
- Hex strings: `"#FF0000"`, `"FF0000"`, `"#F00"`, `"F00"`

**Boolean flags** (set to `true`):
- `:bold`, `:faint`, `:italic`, `:underline`, `:overline`, `:blink`, `:inverse`, `:conceal`

#### Behavior Rules

```ruby
# Multiple colors: last one wins
TIntMe[:red, :blue, :green]                  # => foreground: :green

# Duplicate flags: idempotent (no error)  
TIntMe[:bold, :italic, :bold]                # => bold: true, italic: true

# Keyword arguments override positional
TIntMe[:red, foreground: :blue]              # => foreground: :blue
TIntMe[:bold, bold: false]                   # => bold: false

# Mix freely for complex styling
TIntMe[:red, :bold, background: :yellow, underline: :double]
```

### Color Options

```ruby
# Standard colors (keyword arguments)
TIntMe[foreground: :red]
TIntMe[background: :yellow]

# Standard colors (positional arguments)
TIntMe[:red]                          # Foreground color
TIntMe[:bright_blue]                  # Bright colors supported

# Hex colors (keyword arguments)
TIntMe[foreground: "#FF0000"]
TIntMe[background: "#00FF00"]
TIntMe[foreground: "FF0000"]

# Hex colors (positional arguments)
TIntMe["#FF0000"]                                    # 6-digit with hash
TIntMe["FF0000"]                                     # 6-digit without hash
TIntMe["#F00"]                                       # 3-digit with hash
TIntMe["F00"]                                        # 3-digit without hash

# Mix positional and keyword arguments
TIntMe[:red, background: :yellow]                    # Red foreground, yellow background
TIntMe["#00FF00", :bold, background: :black]         # Green foreground, bold, black background
```

### Text Effects

```ruby
# Individual effects (keyword arguments)
TIntMe[bold: true]
TIntMe[faint: true]                   # Faint/dim text
TIntMe[italic: true]
TIntMe[underline: true]
TIntMe[underline: :double]            # Double underline
TIntMe[overline: true]                # Overline decoration
TIntMe[blink: true]                   # Blinking text
TIntMe[inverse: true]                 # Reverse colors
TIntMe[conceal: true]                 # Hidden/concealed text

# Individual effects (positional arguments)
TIntMe[:bold]                         # Bold text
TIntMe[:italic]                       # Italic text
TIntMe[:underline]                    # Underlined text

# Multiple effects (keyword arguments)
TIntMe[foreground: :green, bold: true, underline: true]

# Multiple effects (positional arguments)
TIntMe[:bold, :italic, :underline]                   # Multiple boolean flags
TIntMe[:red, :bold, :italic]                         # Color + effects
TIntMe["#FF5733", :bold, :underline, :blink]         # Hex color + effects

# Mixed approaches
TIntMe[:bold, :italic, background: :yellow]          # Positional flags + keyword background
TIntMe[:red, :bold, underline: :double]              # Positional color/flag + special underline
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
# OR using positional arguments (equivalent)
ERROR_STYLE = TIntMe[:red] >> TIntMe[:bold]
ERROR_STYLE.call("Error message")            # Fast: ~4.8M operations/sec

# ❌ AVOID: Runtime composition
(TIntMe[foreground: :red] >> TIntMe[bold: true]).call("Error")  # Slow: ~0.01M ops/sec
(TIntMe[:red] >> TIntMe[:bold]).call("Error")                   # Also slow: ~0.01M ops/sec
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
  error:   TIntMe[:red, :bold],                      # Concise positional syntax
  success: TIntMe[foreground: :green, bold: true],   # Or keyword arguments
  warning: TIntMe[:yellow] >> TIntMe[:bold],         # Or use composition (combining styles)
  info:    TIntMe[:blue, :italic]
}

def show_error(msg)
  puts UI_STYLES[:error].call(msg)          # Extremely fast: ~4.8M ops/sec
end
```

**Consider alternatives for:**
```ruby
# Dynamic styling (use Paint gem instead)
texts.each { |text| Paint[text, :red, :bold] }          # ~2M ops/sec

# One-time styling with readable syntax (use Rainbow gem)
puts Rainbow("Success").green.bold                      # ~0.5M ops/sec

# Avoid with TIntMe - creates unnecessary overhead
texts.each { |text| (red >> bold).call(text) }          # Only ~0.01M ops/sec
```

**Design Philosophy:**
TIntMe is intentionally optimized for the **"define once, use many"** pattern through SGR sequence pre-computation at initialization time. The performance characteristics guide you toward the most efficient usage patterns, where a small set of predefined styles serves many styling operations.

### Method Aliases

```ruby
style = TIntMe[foreground: :red, bold: true]

# All of these are equivalent
puts style.call("Hello")
puts style["Hello"]
puts style.("Hello")                  # Callable syntax
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb` and update the CHANGELOG.md, then create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org). However, there are GitHub Actions workflows set up to automate these processes, so please use those instead. See `RELEASING.md` for details.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sakuro/tint_me.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
