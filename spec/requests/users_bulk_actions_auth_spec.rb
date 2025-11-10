require "rails_helper"

RSpec.describe "Users bulk actions auth & functionality", type: :request do
  let!(:exec_user)     { create(:user, :exec) }
  let!(:non_exec_user) { create(:user) }
  let!(:users)         { create_list(:user, 3, status: :active) }
  let!(:inactive_users) { create_list(:user, 2, status: :inactive) }

  # Shared examples for actions requiring exec users
  RSpec.shared_examples "requires exec user" do
    context "when not signed in" do
      it "redirects to login" do
        action.call
        expect(response).to redirect_to(login_path)
      end
    end

    context "when signed in as non-exec user" do
      before do
        Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
        sign_in non_exec_user
      end

      it "redirects non-exec users to login" do
        action.call
        expect(response).to redirect_to(login_path)
      end
    end
  end

  # ---------- BULK EDIT ----------
  describe "bulk_edit" do
    let(:action) { -> { get bulk_edit_users_path, params: { user_ids: users.map(&:id) } } }

    it_behaves_like "requires exec user"

    context "when signed in as exec user" do
      before do
        Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
        sign_in exec_user
        get bulk_edit_users_path, params: { user_ids: users.map(&:id) }
      end

      it "allows exec user to view bulk_edit" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  # ---------- BULK UPDATE ----------
  describe "bulk_update" do
    let(:bulk_params) do
      {
        user_ids: users.map(&:id),
        bulk_update: {
          status: "inactive",
          major: "Updated Major"
        }
      }
    end

    let(:action) { -> { patch bulk_update_users_path, params: bulk_params } }

    it_behaves_like "requires exec user"

    context "when signed in as exec user" do
      before do
        Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
        sign_in exec_user
        patch bulk_update_users_path, params: bulk_params
      end

      it "allows exec user to update users" do
        users.each do |u|
          expect(u.reload.status).to eq("inactive")
          expect(u.reload.major).to eq("Updated Major")
        end
      end
    end
  end

  # ---------- RESET INACTIVE ----------
  describe "reset_inactive" do
    let(:action) { -> { post reset_inactive_users_path } }

    it_behaves_like "requires exec user"

    context "when signed in as exec user" do
      before do
        Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
        sign_in exec_user
        post reset_inactive_users_path
      end

      it "resets inactive users to active" do
        inactive_users.each do |u|
          expect(u.reload.status).to eq("active")
        end
      end
    end
  end
end
