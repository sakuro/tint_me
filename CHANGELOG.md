## [Unreleased]

### Added
- Core Style class with immutable data structure using Data.define (extracted from Fasti gem)
- Support for foreground/background colors (named colors, hex values)
- Text effects: bold, faint, italic, underline (including double), overline, blink, hide, inverse
- Style composition with >> operator for layering styles
- Bold/faint mutual exclusion handling in composition
- TIntMe[] shortcut method for convenient style creation
- Style#call and Style#[] methods for applying styles to text
- Paint gem integration for ANSI escape code generation
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
