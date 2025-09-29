FactoryBot.define do
  factory :resource do
    association :resource_category
    name { "Test Resource" }
    content { "Some optional description" }
    visibility { :public_resource }
    published { true }

    # Attach a file using ActiveStorage test helpers
    after(:build) do |resource|
      resource.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.pdf")),
        filename: "test.pdf",
        content_type: "application/pdf"
      )
    end
  end
end