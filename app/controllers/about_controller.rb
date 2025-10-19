class AboutController < ApplicationController
  before_action :require_exec!, only: [ :edit, :update ]

  def index
    @sections = AboutPageStore.read
  end

  def edit
    @sections = AboutPageStore.read
  end

  def update
    inputs = AboutPageStore::SECTION_KEYS.to_h { |k| [ k.to_s, params.dig(:about_page, k) ] }
    AboutPageStore.save_all!(inputs: inputs, user: current_user)
    redirect_to about_path, notice: "About page updated."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    @sections = AboutPageStore.read
    render :edit, status: :unprocessable_entity
  end
end
