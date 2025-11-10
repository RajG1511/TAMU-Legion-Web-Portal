require "rails_helper"

RSpec.describe "Users CRUD smoke tests", type: :request do
  let!(:exec) { create(:user, :exec) }
  let!(:existing) { create(:user) }

  describe "GET /users" do
    it "redirects non-execs" do
      login_as(existing, scope: :user)
      get users_path
      expect(response).to have_http_status(:redirect)
      expect(response.location).to match(/(login|member_directory|sign_in|users)/)
    end

    it "succeeds for execs" do
      login_as(exec, scope: :user)
      get users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/new" do
    it "redirects non-execs" do
      login_as(existing, scope: :user)
      get new_user_path
      expect(response).to have_http_status(:redirect)
      expect(response.location).to match(/(login|member_directory|sign_in|users)/)
    end

    it "succeeds for execs" do
      login_as(exec, scope: :user)
      get new_user_path
      expect(response).to have_http_status(:ok)
    end
  end
end
