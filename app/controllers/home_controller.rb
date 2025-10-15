class HomeController < ApplicationController
  # Public home page (for all users)
  def index
    @sections = HomePageStore.read
  end

  # Only exec/president can edit or update the homepage
  before_action :require_exec!, only: [:edit, :update]

  def edit
    @sections = HomePageStore.read
  end

  def update
    inputs = HomePageStore::SECTION_KEYS.to_h { |key| [key, params.dig(:home_page, key)] }
    HomePageStore.save_all!(inputs: inputs, user: current_user)
    redirect_to root_path, notice: "Home page updated successfully."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    @sections = HomePageStore.read
    render :edit, status: :unprocessable_entity
  end
end

