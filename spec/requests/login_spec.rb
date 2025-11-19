require 'rails_helper'

RSpec.describe "Login via Google OAuth2", type: :request do
     before do
          OmniAuth.config.test_mode = true
     end

  after do
       OmniAuth.config.test_mode = false
  end

  # Helper to mock Google OAuth
  def mock_omniauth(user)
       OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
         provider: 'google_oauth2',
         uid: SecureRandom.hex(8),
         info: {
           email: user.email,
           name: "#{user.first_name} #{user.last_name}",
           image: user.image_url
         }
       )
  end

  describe "GET /users/auth/google_oauth2/callback" do
       context "sunny day: member logs in" do
            let!(:member) { create(:user, :member, email: "member@tamu.edu") }

         before do
              mock_omniauth(member)
           get user_google_oauth2_omniauth_callback_path
         end

         it "signs in the member" do
              expect(controller.current_user).to eq(member)
         end

         it "redirects to member center" do
              expect(response).to redirect_to(member_center_path)
         end

         it "sets a success flash message" do
              expect(flash[:success]).to eq("Successfully authenticated from Google account.")
         end
       end

    context "sunny day: executive logs in" do
         let!(:exec) { create(:user, :exec, email: "exec@tamu.edu") }

      before do
           mock_omniauth(exec)
        get user_google_oauth2_omniauth_callback_path
      end

      it "signs in the executive" do
           expect(controller.current_user).to eq(exec)
      end

      it "redirects to member center" do
           expect(response).to redirect_to(member_center_path)
      end
    end

    context "rainy day: non-member or unregistered user" do
         let(:non_member_email) { "nonmember@tamu.edu" }

      before do
           OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
             provider: 'google_oauth2',
             uid: SecureRandom.hex(8),
             info: {
               email: non_member_email,
               name: "Unregistered User",
               image: "https://example.com/avatar.png"
             }
           )
        get user_google_oauth2_omniauth_callback_path
      end

      it "does not sign in the user" do
           expect(controller.current_user).to be_nil
      end

      it "redirects to the login page" do
           expect(response).to redirect_to(login_path)
      end

      it "sets an alert flash message" do
           expect(flash[:alert]).to eq("You are not authorized. Please contact an executive.")
      end
    end
  end
end
