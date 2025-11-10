require "rails_helper"

RSpec.describe "User sessions", type: :request do
     let(:user) { create(:user, password: "password123") }

  before { Warden.test_mode! }
  after  { Warden.test_reset! }

  describe "sign in" do
       it "signs in the user" do
            login_as(user, scope: :user)  # <- works in request specs with Warden

         get member_center_path
         expect(response).to have_http_status(:ok)
         expect(response.body).to include("Member Center") # adjust text for your page
       end
  end

  describe "sign out" do
       it "signs out the user" do
            login_as(user, scope: :user)
         delete destroy_user_session_path

         expect(response).to redirect_to(login_path)
       end
  end
end
