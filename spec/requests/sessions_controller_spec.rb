require 'rails_helper'

RSpec.describe "User sessions", type: :request do
  let(:user) { create(:user, password: "password123") }

  describe "POST /users/sign_in" do
    it "redirects to login_path after sign in" do
      post user_session_path, params: {
        user: { email: user.email, password: "password123" }
      }

      expect(response).to redirect_to(login_path)
    end
  end

  describe "DELETE /users/sign_out" do
    it "redirects to login_path after sign out" do
      # First sign in
      sign_in user

      delete destroy_user_session_path

      expect(response).to redirect_to(login_path)
    end
  end
end