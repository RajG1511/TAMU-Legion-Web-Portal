# spec/system/committees_spec.rb
require 'rails_helper'

RSpec.describe "Committees", type: :system do
     include Warden::Test::Helpers

  let(:new_user) { create(:user, first_name: 'Test', last_name: 'User') }

  before do
       Warden.test_mode!
    driven_by(:rack_test)
  end

  after do
       Warden.test_reset!
  end

  # Use FactoryBot for user creation
  def sign_in_as_exec!
       user = create(:user, :exec) # uses factory and sets password
    login_as(user, scope: :user)
  end

  context 'As an executive' do
       it 'I can add or remove someone to a committee' do
            sign_in_as_exec!

         visit committees_path
         expect(page).to have_content('Committees')
         visit new_committee_path
         fill_in 'Name', with: 'Test Committee'
         click_button 'Create Committee'

         committee = Committee.find_by(name: 'Test Committee')

         visit committee_path(committee)
         within(:xpath, "//form[.//h2[contains(.,'Add Member')]]") do
              select new_user.full_name, from: "user_id"
           click_button "Add Member"
         end

         expect(page).to have_content(new_user.full_name)

         visit committee_path(committee)
         within(:xpath, "//form[.//h2[contains(.,'Remove Member')]]") do
              select new_user.full_name, from: "user_id"
           click_button "Remove Member"
         end

         visit committee_path(committee)
         expect(page).not_to have_content('<p>' + new_user.full_name + '</p>')
       end
  end


  it 'lists committees and allows execs to create, edit, and delete' do
       sign_in_as_exec!

    # Visit index
    visit committees_path
    expect(page).to have_content('Committees')

    # Create a new committee
    visit new_committee_path
    fill_in 'Name', with: 'Test Committee'
    click_button 'Create Committee'

    committee = Committee.find_by(name: 'Test Committee')

    # Check committee page content
    expect(page).to have_content('Test Committee')
    expect(page).to have_current_path(committee_path(committee))

    # Edit the committee
    visit edit_committee_path(committee)
    fill_in 'Description', with: 'Updated description for test committee'
    click_button 'Update Committee'

    expect(page).to have_content('Updated description for test committee')
    expect(page).to have_current_path(committee_path(committee))

    # Delete the committee
    visit delete_committee_path(committee)
    click_button 'Delete'

    # flash message is still correct
    expect(page).to have_content('Committee Test Committee deleted.')

    # check that the committee is no longer in the list
    within('#committee-list') do
         expect(page).not_to have_content('Test Committee')
    end
  end

  it 'shows a committee page to any user' do
       committee = create(:committee, name: 'Committee Name', description: 'Committee Description')

    visit committee_path(committee)
    expect(page).to have_content('Committee Name')
    expect(page).to have_content('Committee Description')
  end
end
