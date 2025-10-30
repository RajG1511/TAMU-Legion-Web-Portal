FactoryBot.define do
  factory :service do
    association :user   # assumes you have a User factory
    name        { "Test Service" }
    description { "Some description" }
    hours       { 2 }
    date_performed { Date.today }
    committee   { "events" }   # pick one of your valid committees
    status      { :pending }   # default status
  end
end