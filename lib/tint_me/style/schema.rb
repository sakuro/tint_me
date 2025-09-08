# frozen_string_literal: true

require "dry-schema"

module TIntMe
  class Style
    # Schema for validating Style initialization arguments
    Schema = Dry::Schema.Params {
      optional(:foreground).value(Types::Color)
      optional(:background).value(Types::Color)
      optional(:inverse).value(Types::BooleanOption)
      optional(:bold).value(Types::BooleanOption)
      optional(:faint).value(Types::BooleanOption)
      optional(:underline).value(Types::UnderlineOption)
      optional(:overline).value(Types::BooleanOption)
      optional(:blink).value(Types::BooleanOption)
      optional(:italic).value(Types::BooleanOption)
      optional(:hide).value(Types::BooleanOption)
    }
    private_constant :Schema
  end
end
