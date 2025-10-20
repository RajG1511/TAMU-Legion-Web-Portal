require "rails_helper"

RSpec.describe Resource, type: :model do
     let(:category) { create(:resource_category) }

  context "validations" do
       it "is valid with all required attributes for a file" do
            resource = build(:resource, :with_file, resource_category: category)
         expect(resource).to be_valid
       end

    it "is valid for a link resource" do
         resource = build(:resource, :link_resource, resource_category: category)
      expect(resource).to be_valid
    end

    it "is invalid without a name" do
         resource = build(:resource, name: nil)
      expect(resource).not_to be_valid
      expect(resource.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a category" do
         resource = build(:resource, resource_category: nil)
      expect(resource).not_to be_valid
      expect(resource.errors[:resource_category_id]).to include("can't be blank")
    end

    it "is invalid without a file for a file resource" do
         resource = build(:resource, resource_type: "file", resource_category: category)
      resource.file.detach if resource.file.attached?
      expect(resource).not_to be_valid
      expect(resource.errors[:file]).to include("can't be blank")
    end

    it "is invalid with wrong file type" do
         resource = build(:resource, :with_file, resource_category: category)
      resource.file.detach
      resource.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
        filename: "test.txt",
        content_type: "text/plain"
      )
      expect(resource).not_to be_valid
      expect(resource.errors[:file].first).to include("has an invalid content type")
    end

    it "is invalid without content for a link resource" do
         resource = build(:resource, :link_resource, content: nil)
      expect(resource).not_to be_valid
      expect(resource.errors[:content]).to include("can't be blank")
    end

    it "is invalid with invalid URL for a link resource" do
         resource = build(:resource, :link_resource, content: "invalid-url")
      expect(resource).not_to be_valid
      expect(resource.errors[:content]).to include("must be a valid URL")
    end
  end

  context "scopes" do
       it "returns only published resources" do
            published = create(:resource, :with_file, published: :published)
         unpublished = create(:resource, :with_file, published: :draft)
         expect(Resource.published).to include(published)
         expect(Resource.published).not_to include(unpublished)
       end
  end

  context "visibility" do
       let(:public_resource)  { create(:resource, :with_file, visibility: :public_resource) }
    let(:members_only)     { create(:resource, :with_file, visibility: :members_only) }
    let(:execs_only)       { create(:resource, :with_file, visibility: :execs_only) }

    it "returns correct resources for a nil user" do
         expect(Resource.visible_to(nil)).to match_array([ public_resource ])
    end

    it "returns correct resources for a member" do
         user = double("user", member?: true, exec?: false, president?: false, nonmember?: false)
      expect(Resource.visible_to(user)).to match_array([ public_resource, members_only ])
    end

    it "returns correct resources for an exec" do
         user = double("user", member?: false, exec?: true, president?: false, nonmember?: false)
      expect(Resource.visible_to(user)).to match_array([ public_resource, members_only, execs_only ])
    end
  end
end
