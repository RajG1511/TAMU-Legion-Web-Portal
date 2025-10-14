class HomeController < ApplicationController
  def index
    @user = current_user
  end

  # Member Login Page
  def login
    redirect_to member_center_path if user_signed_in?
  end

  def member_center
    unless user_signed_in?
      redirect_to login_path, alert: "Please sign in to continue."
      return
    end
    @user = current_user
  end
end
