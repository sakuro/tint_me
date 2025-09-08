# TIntMe! :art:

A Ruby library for terminal text styling with ANSI colors and effects. TIntMe! provides an elegant and composable API for applying colors, text decorations, and formatting to terminal output.

## Features

- **Rich Color Support**: Foreground and background colors with support for standard colors and hex values
- **Text Effects**: Bold, italic, underline, overline, blink, faint, inverse, and concealed text
- **Style Composition**: Combine multiple styles using the `>>` operator for layered styling
- **Immutable Design**: All style operations return new instances, making them safe for concurrent use
- **Zeitwerk Integration**: Automatic loading with proper module organization
- **Comprehensive API**: Both explicit `Style.new` and convenient `TIntMe[]` shortcut syntax

## Installation

Add this line to your application's Gemfile:

```bash
bundle add tint_me
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
TIntMe[italic: true]
TIntMe[underline: true]
TIntMe[underline: :double]  # Double underline
TIntMe[conceal: true]       # Hidden/concealed text

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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tint_me.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
