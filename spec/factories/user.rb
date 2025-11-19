FactoryBot.define do
     factory :user do
          sequence(:email)      { |n| "user#{n}@example.com" }
       first_name            { "Test" }
       last_name             { "User" }
       status                { :active }
       role                  { :member }
       major                 { "Computer Science" }
       graduation_year       { 2026 }
       t_shirt_size          { "M" }
       position              { nil }
       image_url             { "https://example.com/avatar.png" }
       password              { "password123" }
       password_confirmation { "password123" }

       trait :inactive do
            status { :inactive }
       end

       trait :exec do
            role { :exec }
       end

       trait :president do
            role     { :president }
         position { "President" } # required by your custom validation
       end

       trait :nonmember do
            role { :nonmember }
       end
     end
end
