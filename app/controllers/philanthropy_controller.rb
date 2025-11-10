class PhilanthropyController < ApplicationController
     before_action :require_exec!, only: [ :edit, :update ]

  def index
       @sections = PhilanthropyPageStore.read
  end

  def edit
       @sections = PhilanthropyPageStore.read
    page = Page.find_by(slug: "philanthropy")
    @philanthropy_versions = PageVersion
      .for_page(page)
      .order("page_versions.created_at DESC", :created_at)
  end

  def update
       inputs = PhilanthropyPageStore::SECTION_KEYS.to_h { |k| [ k.to_s, params.dig(:philanthropy_page, k) ] }
       PhilanthropyPageStore.save_all!(inputs: inputs, user: current_user)
       redirect_to philanthropy_path, notice: "Philanthropy page updated."
     rescue ActiveRecord::RecordInvalid => e
          flash.now[:alert] = e.record.errors.full_messages.to_sentence
       @sections = PhilanthropyPageStore.read
       render :edit, status: :unprocessable_entity
  end
end
