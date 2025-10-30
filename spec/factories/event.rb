FactoryBot.define do
     factory :event do
          association :event_category

       sequence(:name) { |n| "Sample Event #{n}" }
       description     { "This is a test event." }

       starts_at   { 1.day.from_now }
       ends_at     { 2.days.from_now }

       visibility  { :public_event }
       published   { :draft }

       location_type { "campus" }
       campus_code   { "ENGR" }
       campus_number { 101 }

       trait :off_campus do
            location_type { "off_campus" }
         location_name { "Convention Center" }
         address       { "123 Main St" }
         campus_code   { nil }
         campus_number { nil }
       end

       trait :other_location do
            location_type { "other_location" }
         location_text { "Virtual" }
         campus_code   { nil }
         campus_number { nil }
       end

       trait :published do
            published { :published }
       end

       trait :unpublished do
            published { :unpublished }
       end
     end
end
