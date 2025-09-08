# frozen_string_literal: true

require "dry-schema"

module TIntMe
  class Style
    # Schema for validating Style initialization arguments
    Schema = Dry::Schema.define {
      optional(:foreground).maybe(Types::Color)
      optional(:background).maybe(Types::Color)
      optional(:inverse).value(Types::BooleanOption)
      optional(:bold).value(Types::BooleanOption)
      optional(:faint).value(Types::BooleanOption)
      optional(:underline).value(Types::UnderlineOption)
      optional(:overline).value(Types::BooleanOption)
      optional(:blink).value(Types::BooleanOption)
      optional(:italic).value(Types::BooleanOption)
      optional(:conceal).value(Types::BooleanOption)
    }
    private_constant :Schema
  end
end
