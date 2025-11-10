require 'rails_helper'

RSpec.describe AnnouncementsController, type: :request do
     describe "POST /create" do
          let(:message) { "Big news!" }

       it "updates the current announcement and redirects" do
            post announcements_path, params: { announcement: { message: message } }

         expect(Announcement.current.message).to eq(message)
         expect(response).to redirect_to(root_path) # fallback_location used in controller
       end
     end

  describe "DELETE /destroy" do
     before { Announcement.current.update!(message: "Some message") }

  it "clears the current announcement message and redirects" do
       delete end_announcement_path   # use the route helper

    expect(Announcement.current.message).to be_nil
    expect(response).to redirect_to(root_path)
  end
end
end
