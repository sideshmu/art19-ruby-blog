# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    title   { "Sample title" }
    body    { "Sample body which is long" }
    status  { "public" }        
  end
end
