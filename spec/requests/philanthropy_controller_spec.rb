require "rails_helper"

RSpec.describe PhilanthropyController, type: :controller do
  let(:sections) { { "hero" => "content" } }
  let(:page)     { Page.new } # real AR model
  let(:version1) { instance_double(PageVersion) }
  let(:version2) { instance_double(PageVersion) }
  let(:relation) { double("PageVersion::Relation") }
  let(:user)     { double("User", exec?: true, president?: false) }

  before do
    allow(PhilanthropyPageStore).to receive(:read).and_return(sections)
    allow(Page).to receive(:find_by).with(slug: "philanthropy").and_return(page)
    allow(PageVersion).to receive(:for_page).with(page).and_return(relation)
    allow(relation).to receive(:order).and_return([version1, version2])
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    it "assigns sections from the store" do
      get :index
      expect(assigns(:sections)).to eq(sections)
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "assigns sections and versions" do
      get :edit
      expect(assigns(:sections)).to eq(sections)
      expect(assigns(:philanthropy_versions)).to eq([version1, version2])
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    let(:params) { { philanthropy_page: { "hero" => "new content" } } }

    context "when save succeeds" do
      before { allow(PhilanthropyPageStore).to receive(:save_all!).and_return(true) }

      it "redirects with notice" do
        patch :update, params: params
        expect(response).to redirect_to(philanthropy_path)
        expect(flash[:notice]).to eq("Philanthropy page updated.")
      end
    end

    context "when save raises RecordInvalid" do
      let(:invalid_page) { Page.new }

      before do
        invalid_page.validate # populate errors
        allow(PhilanthropyPageStore).to receive(:save_all!).and_raise(
          ActiveRecord::RecordInvalid.new(invalid_page)
        )
      end

      it "renders edit with alert" do
        patch :update, params: params
        expect(assigns(:sections)).to eq(sections)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:alert]).to be_present
      end
    end
  end
end