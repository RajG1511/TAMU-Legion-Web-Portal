require 'rails_helper'

describe 'Contact Page', type: :system do
     include Warden::Test::Helpers
  before(:each) { Warden.test_mode! }
  after(:each)  { Warden.test_reset! }

  let(:user) { create(:user, password: "password123") }
  let(:exec) { create(:user, :exec, password: "password123") }

  before do
       driven_by(:rack_test) # stays on rack_test, no JS required
  end

  context "As a nonmember" do
       it "I can see the contact page" do
            visit contact_path
         expect(page).to have_content("Contact Us")
       end
  end
end
