class ContactController < ApplicationController
     before_action :require_exec!, only: [ :edit, :update ]

  def index
       @sections = ContactPageStore.read
  end

  def edit
       @sections = ContactPageStore.read
  end

  def update
       inputs = ContactPageStore::SECTION_KEYS.to_h { |k| [ k.to_s, params.dig(:contact_page, k) ] }
       ContactPageStore.save_all!(inputs: inputs, user: current_user)
       redirect_to contact_path, notice: "Contact page updated."
     rescue ActiveRecord::RecordInvalid => e
          flash.now[:alert] = e.record.errors.full_messages.to_sentence
       @sections = ContactPageStore.read
       render :edit, status: :unprocessable_entity
  end
end
