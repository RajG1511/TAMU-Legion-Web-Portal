require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:exec) { create(:user, role: :exec, status: :active) }
  let(:user) { create(:user, role: :member, status: :active) }

  before do
    allow(controller).to receive(:current_user).and_return(exec)
  end

  describe "#ensure_self_or_exec!" do
    it "allows exec" do
      get :show, params: { id: user.id }
      expect(response).to be_successful
    end

    it "allows self" do
      allow(controller).to receive(:current_user).and_return(user)
      get :show, params: { id: user.id }
      expect(response).to be_successful
    end

    it "redirects otherwise" do
      stranger = create(:user)
      allow(controller).to receive(:current_user).and_return(stranger)
      get :show, params: { id: user.id }
      expect(response).to redirect_to(member_directory_path)
      expect(flash[:alert]).to eq("You can only view your own profile.")
    end
  end

  describe "GET #public_index" do
    it "assigns execs and committees" do
      committee = create(:committee)
      get :public_index
      expect(assigns(:execs)).to all(be_a(User))
      expect(assigns(:committees)).to include(committee)
    end
  end

  describe "GET #index" do
    it "shows inactive when param set" do
      get :index, params: { show_inactive: "1" }
      expect(assigns(:users)).to all(be_a(User))
    end

    it "applies search when q present" do
      allow(User).to receive(:search).and_return(User.none)
      get :index, params: { q: "test" }
      expect(assigns(:users)).to be_empty
    end
  end

  describe "GET #directory" do
    it "returns all members when no query" do
      get :directory
      expect(assigns(:users)).to all(be_a(User))
    end

    it "filters by query" do
      get :directory, params: { q: user.first_name }
      expect(assigns(:users)).to include(user)
    end

    it "filters by role keyword" do
      get :directory, params: { q: "exec" }
      expect(assigns(:users)).to all(be_a(User))
    end
  end

  describe "GET #new" do
    it "assigns a new user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST #create" do
    it "creates successfully" do
      post :create, params: { user: attributes_for(:user) }
      expect(response).to redirect_to(users_path)
      expect(flash[:success]).to eq("User created.")
    end

    it "fails to create" do
      post :create, params: { user: { email: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(flash.now[:error]).to match(/User not created/)
    end
  end

  describe "PATCH #update" do
    it "updates successfully" do
      patch :update, params: { id: user.id, user: { first_name: "New" } }
      expect(response).to redirect_to(users_path)
      expect(flash[:success]).to eq("User updated.")
    end

    it "fails to update" do
      patch :update, params: { id: user.id, user: { email: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(flash.now[:error]).to match(/User not updated/)
    end
  end

  describe "GET #delete" do
    it "renders delete" do
      get :delete, params: { id: user.id }
      expect(response).to be_successful
    end
  end

  # DELETE #destroy intentionally omitted

  describe "POST #bulk_edit" do
    it "assigns users when ids present" do
      post :bulk_edit, params: { user_ids: [user.id] }
      expect(assigns(:users)).to include(user)
    end

    it "redirects when no ids" do
      post :bulk_edit, params: { user_ids: [] }
      expect(response).to redirect_to(users_path)
      expect(flash[:alert]).to eq("Please select users to edit")
    end
  end

  describe "PATCH #bulk_update" do
    it "updates users when params present" do
      patch :bulk_update, params: { user_ids: [user.id], bulk_update: { status: "inactive" } }
      expect(response).to redirect_to(users_path)
      expect(flash[:success]).to match(/users updated successfully/)
    end

    it "alerts when no updates" do
      patch :bulk_update, params: { user_ids: [], bulk_update: {} }
      expect(response).to redirect_to(users_path)
      expect(flash[:alert]).to eq("No fields selected for update")
    end
  end

  describe "POST #reset_inactive" do
    it "resets inactive users" do
      inactive = create(:user, status: :inactive)
      post :reset_inactive
      expect(response).to redirect_to(users_path)
      expect(flash[:success]).to match(/Reset/)
    end
  end

  describe "POST #update_member_center_caption" do
    it "rejects blank caption" do
      post :update_member_center_caption, params: { text: "" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Caption cannot be empty!")
    end

    it "writes file and redirects" do
      allow(File).to receive(:write)
      post :update_member_center_caption, params: { text: "<a href='x'>ok</a>" }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Member Center Caption updated!")
    end
  end

  describe "private helpers" do
    it "changed_diff returns differences" do
      before = { "email" => "a" }
      after  = { "email" => "b" }
      diff = controller.send(:changed_diff, before, after)
      expect(diff["email"]).to eq({ before: "a", after: "b" })
    end

    it "log_user_change rescues errors" do
      allow(UserVersion).to receive(:create!).and_raise("fail")
      expect {
        controller.send(:log_user_change, user, :updated, summary: "x")
      }.not_to raise_error
    end
  end
end