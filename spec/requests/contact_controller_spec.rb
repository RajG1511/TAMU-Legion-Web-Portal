require 'rails_helper'

RSpec.describe "ContactController", type: :request do
     let(:exec)   { create(:user, role: :exec) }
  let(:member) { create(:user, role: :member) }

  before do
       # Stub ContactPageStore.read so views don’t blow up
       allow(ContactPageStore).to receive(:read).and_return({ "email" => "test@example.com" })
  end

  describe "GET /contact" do
       it "renders the index page" do
            get contact_path
         expect(response).to have_http_status(:ok)
         expect(response.body).to include("Contact")
       end
  end

  describe "GET /contact/edit" do
       context "as exec" do
            before { sign_in exec }

         it "renders the edit page" do
              get edit_contact_path
           expect(response).to have_http_status(:ok)
         end
       end

    context "as member" do
         before { sign_in member }

      it "redirects unauthorized users" do
           get edit_contact_path
        expect(response).to redirect_to(root_path).or redirect_to(login_path)
      end
    end
  end

  describe "PATCH /contact" do
       before { sign_in exec }

    context "with valid params" do
         it "saves and redirects" do
              allow(ContactPageStore).to receive(:save_all!).and_return(true)

           patch contact_path, params: { contact_page: { "email" => "new@example.com" } }

           expect(response).to redirect_to(contact_path)
           follow_redirect!
           expect(response.body).to include("Contact page updated.")
         end
    end

    context "when save raises RecordInvalid" do
         it "renders edit with alert" do
              invalid_user = User.new # has validations
           allow(ContactPageStore).to receive(:save_all!)
             .and_raise(ActiveRecord::RecordInvalid.new(invalid_user))

           patch contact_path, params: { contact_page: { "email" => "" } }

           expect(response).to have_http_status(:unprocessable_entity)
           # flash.now[:alert] is rendered in the body, not persisted
           expect(response.body).to match(/error|blank|invalid/i)
         end
    end
  end
end
