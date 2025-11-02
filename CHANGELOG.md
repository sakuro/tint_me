## [Unreleased]

## [1.1.0] - 2025-11-02

### Added
- **Positional Arguments Support**: New concise syntax for style creation
  - Single color as positional argument: `TIntMe[:red]` sets foreground
  - Two colors as positional arguments: `TIntMe[:red, :yellow]` sets foreground and background
  - Boolean flags as positional arguments: `TIntMe[:bold, :italic]`
  - Mixed usage: `TIntMe[:red, :yellow, :bold, background: :blue]`
  - Support for all color formats: symbols, hex strings (with/without #, 3/6 digits)
  - Maximum 2 color arguments allowed (3+ raises ArgumentError)
  - Keyword arguments take precedence over positional arguments
- Type safety with dry-types `PositionalArgumentsArray` validation
- Comprehensive test coverage for all positional argument scenarios

### Development
- Improved release workflow branch cleanup with existence check

## [1.0.0] - 2025-09-09

### Added
- Core Style class with immutable data structure using Data.define (extracted from Fasti gem)
- Support for foreground/background colors (named colors, hex values)
- Text effects: bold, faint, italic, underline (including double), overline, blink, hide, inverse
- Style composition with >> operator for layering styles
- Bold/faint mutual exclusion handling in composition
- TIntMe[] shortcut method for convenient style creation
- Style#call and Style#[] methods for applying styles to text
- Native ANSI SGR implementation with comprehensive color and effect support
- Zeitwerk autoloader with custom inflection rules for TIntMe
- Comprehensive test suite with 100% code coverage
- SimpleCov integration for coverage reporting
- YARD documentation generation with redcarpet markdown support
- RuboCop configuration with systematic violation resolution
- Rake tasks for testing, linting, and documentation generation

### Development
- Complete project setup with proper gem structure
- Git configuration with appropriate .gitignore patterns
- Bundler gem tasks integration
- RSpec test framework with progress format output
- Development dependencies: RuboCop, YARD, SimpleCov
- Continuous integration ready configuration
- Comprehensive AI agent guidelines for Git/PR operations and language usage
- Performance guidelines for style composition optimization
