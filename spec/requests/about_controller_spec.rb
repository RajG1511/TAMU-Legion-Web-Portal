require 'rails_helper'

RSpec.describe "AboutController", type: :request do
     let(:exec) { create(:user, role: :exec) }
  let(:non_exec) { create(:user) }

  before do
       # Stub AboutPageStore.read so views don’t blow up
       allow(AboutPageStore).to receive(:read).and_return({
         "what_is_title" => "Original Title",
         "what_is_body_html" => "Original Body",
         "facts_title" => "Facts Title",
         "fact_1" => "Fact 1",
         "fact_2" => "Fact 2",
         "fact_3" => "Fact 3",
         "pillars_title" => "Pillars Title",
         "pillar_1" => "Pillar 1",
         "pillar_2" => "Pillar 2",
         "pillar_3" => "Pillar 3"
       })
  end

  describe "GET /about" do
       it "renders the index page" do
            get about_path
         expect(response).to have_http_status(:ok)
         expect(response.body).to include("About")
       end
  end

  describe "GET /about/edit" do
       context "as exec" do
            before { sign_in exec }

         it "renders the edit page and assigns sections and versions" do
              page = Page.find_or_create_by!(slug: "about", title: "About")
           # Use a valid change_type for PageVersion
           version = PageVersion.create!(
             page: page,
             user: exec,
             change_type: "update" # valid enum/value for PageVersion
           )

           get edit_about_path

           expect(response).to have_http_status(:ok)
           expect(assigns(:sections)).to eq(AboutPageStore.read)
           expect(assigns(:about_versions)).to include(version)
           expect(response.body).to include("Edit About Us Page")
         end
       end
  end

  describe "PATCH /about" do
       let(:valid_params) do
            {
              about_page: {
                "what_is_title" => "New Title",
                "what_is_body_html" => "New Body"
              }
            }
       end

    context "as exec" do
         before { sign_in exec }

      context "with valid params" do
           it "saves and redirects" do
                allow(AboutPageStore).to receive(:save_all!).and_return(true)

             patch about_path, params: valid_params

             expect(response).to redirect_to(about_path)
             follow_redirect!
             expect(response.body).to include("About page updated.")
           end
      end

      context "with invalid params (save fails)" do
           it "renders edit with unprocessable_entity" do
                # Create a real invalid record to raise RecordInvalid properly
                invalid_page = Page.new # missing slug
             allow(AboutPageStore).to receive(:save_all!).and_raise(
               ActiveRecord::RecordInvalid.new(invalid_page)
             )

             patch about_path, params: valid_params

             expect(response).to have_http_status(:unprocessable_entity)
             expect(response.body).to include("Edit About Us Page")
             expect(assigns(:sections)).to eq(AboutPageStore.read)
           end
      end
    end

    context "as non-exec" do
         before { sign_in non_exec }

      it "denies access to edit page" do
           get edit_about_path
        expect(response).to redirect_to("/login")
      end

      it "denies update access" do
           patch about_path, params: valid_params
        expect(response).to redirect_to("/login")
      end
    end
  end
end
