FactoryBot.define do
     factory :resource_category do
          sequence(:name) { |n| "Category #{n}" }
     end
end
