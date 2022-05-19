# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    commenter     { "Bob" }
    body          { "Sample body which is long" }
    status        { "public" }
    approval      { "submitted" }
  end
end
