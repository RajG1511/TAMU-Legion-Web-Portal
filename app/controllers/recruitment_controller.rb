# app/controllers/recruitment_controller.rb
class RecruitmentController < ApplicationController
  # Public page
  def index
    @sections = RecruitmentPageStore.read
  end

  # Optional: lock editing to execs, just like the home page
  before_action :require_exec!, only: [:edit, :update]

  def edit
    @sections = RecruitmentPageStore.read
  end

  def update
    # If you later add an edit form, you can save SectionVersions here
    redirect_to recruitment_path, notice: "Recruitment page updated."
  end
end

