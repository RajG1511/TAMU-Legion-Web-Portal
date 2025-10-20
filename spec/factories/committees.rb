# spec/factories/committees.rb
FactoryBot.define do
     factory :committee do
          sequence(:name) { |n| "Committee #{n}" }
       description { "A description for the committee." }
     end
end
