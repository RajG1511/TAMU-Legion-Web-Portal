# spec/views/users/index_bulk_checkboxes_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/index", type: :view do
     let(:exec)   { create(:user, :exec) }
  let(:member) { create(:user, role: :member) }
  let(:u1)     { create(:user, role: :member) }
  let(:u2)     { create(:user, role: :member, status: :inactive) }

  context "when current_user is an exec" do
       it "renders bulk edit form with user_id checkboxes and the reset button" do
            assign(:users, [ u1, u2 ])
         allow(view).to receive(:current_user).and_return(exec)

         render template: "users/index"

         # Bulk-edit form
         expect(rendered).to include(%(action="#{bulk_edit_users_path}"))
         expect(rendered).to include("Edit Selected Users")

         # Checkboxes for users
         [ u1, u2 ].each do |user|
              expect(rendered).to match(/name="user_ids\[\]".*value="#{user.id}"/)
         end

         # Reset button visible for execs
         expect(rendered).to include(%(action="#{reset_inactive_users_path}"))
       end
  end

  context "when current_user is a member" do
       it "hides the reset button but still shows bulk form" do
            assign(:users, [ member ])
         allow(view).to receive(:current_user).and_return(member)

         render template: "users/index"

         expect(rendered).to include(%(action="#{bulk_edit_users_path}"))
         expect(rendered).to include("Edit Selected Users")
         expect(rendered).not_to include(%(action="#{reset_inactive_users_path}"))
       end
  end
end
