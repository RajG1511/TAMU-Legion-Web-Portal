require "rails_helper"

RSpec.describe Resource, type: :model do
  let(:category) { create(:resource_category) }

  context "validations" do
    it "is valid with all required attributes" do
      resource = build(:resource, resource_category: category)
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
    end

    it "is invalid without a file" do
      resource = build(:resource)
      resource.file.detach
      expect(resource).not_to be_valid
      expect(resource.errors[:file]).to include("must be attached")
    end

    it "is invalid with wrong file type" do
      resource = build(:resource)
      resource.file.detach
      resource.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
        filename: "test.txt",
        content_type: "text/plain"
      )
      expect(resource).not_to be_valid
      expect(resource.errors[:file]).to include("has an invalid content type")
    end
  end

  context "scopes" do
    it "returns only published resources in index scope" do
      published = create(:resource, published: true)
      unpublished = create(:resource, published: false)
      expect(Resource.where(published: true)).to include(published)
      expect(Resource.where(published: true)).not_to include(unpublished)
    end
  end
end