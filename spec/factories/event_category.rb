FactoryBot.define do
  factory :event_category do
    sequence(:name) { |n| "Category #{n}" }
  end
end