require 'rails_helper'

RSpec.describe "Committees", type: :system do
  include Warden::Test::Helpers

  before do
    Warden.test_mode!
    driven_by(:rack_test)
  end

  after do
    Warden.test_reset!
  end

  def sign_in_as_exec!
    user = User.create!(
      email: "member1@org.edu",
      first_name: "Member",
      last_name: "1",
      graduation_year: 2024,
      major: "Computer Science",
      t_shirt_size: "S",
      status: :active,
      role: :exec
    )
    login_as(user, scope: :user)
  end



  it 'lists committees and allows execs to create, edit, and delete' do
    sign_in_as_exec!

    visit committees_path
    expect(page).to have_content('Committees')

    visit new_committee_path
    fill_in 'Name', with: 'Test Committee'
    click_button 'Create Committee'

    committee = Committee.find_by(name: 'Test Committee')
    expect(page).to have_content('Committee Test Committee created.')
    expect(page).to have_current_path(committee_path(committee))
    expect(page).to have_content('Test Committee')

    visit edit_committee_path(committee)
    fill_in 'Description', with: 'Updated description for test committee'
    click_button 'Update Committee'
    expect(page).to have_content('Committee Test Committee updated.')
    expect(page).to have_current_path(committee_path(committee))
    expect(page).to have_content('Updated description for test committee')

    visit delete_committee_path(committee)
    click_button 'Delete'

    expect(page).to have_content('Committee Test Committee deleted.')
    expect(page).to have_current_path(committees_path)
    within('ul') do
      expect(page).not_to have_content('Test Committee')
    end
  end

  it 'shows a committee page to any user' do
    committee = Committee.create(name: 'Committee Name', description: 'Committee Description')
    visit committee_path(committee)
    expect(page).to have_content('Committee Name')
    expect(page).to have_content('Committee Description')
  end
end
