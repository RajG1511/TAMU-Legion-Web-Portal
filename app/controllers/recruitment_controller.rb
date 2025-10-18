# app/controllers/recruitment_controller.rb
class RecruitmentController < ApplicationController
  before_action :require_exec!, only: [:edit, :update]

  def index
    @sections = RecruitmentPageStore.read
  end

  def edit
    @sections = RecruitmentPageStore.read
  end

  def update
    inputs = RecruitmentPageStore::SECTION_KEYS.to_h { |k| [k.to_s, params.dig(:recruitment_page, k)] }
    RecruitmentPageStore.save_all!(inputs: inputs, user: current_user)
    redirect_to recruitment_path, notice: "Recruitment page updated."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    @sections = RecruitmentPageStore.read
    render :edit, status: :unprocessable_entity
  end
end

