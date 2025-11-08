class AnnouncementsController < ApplicationController
  def create
    Announcement.current.update!(announcement_params)
    redirect_back fallback_location: root_path, notice: "Announcement published."
  end

  def destroy
    Announcement.current.update!(message: nil)
    redirect_back fallback_location: root_path, notice: "Announcement ended."
  end

  private

  def announcement_params
    params.require(:announcement).permit(:message)
  end
end