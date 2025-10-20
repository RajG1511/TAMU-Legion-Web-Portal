FactoryBot.define do
     factory :resource do
          association :resource_category
       name { "Test Resource" }
       visibility { :public_resource }
       published { :published }   # match enum
       resource_type { "file" }   # default to file

       # file attachment for file-type resources
       trait :with_file do
            after(:build) do |resource|
                 resource.file.attach(
                   io: File.open(Rails.root.join("spec/fixtures/files/test.pdf")),
                   filename: "test.pdf",
                   content_type: "application/pdf"
                 )
            end
       end

       # link-type resource
       trait :link_resource do
            resource_type { "link" }
         content { "https://example.com" }
       end

       # exec-only visibility
       trait :exec_only do
            visibility { :execs_only }
       end

       # members-only visibility
       trait :members_only do
            visibility { :members_only }
       end
     end
end
