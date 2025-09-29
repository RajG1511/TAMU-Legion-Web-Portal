class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_user

  private

  def current_user
    if params[:as] == "role2"
      User.find_by(email: "role2@example.com")
    else
      User.find_by(email: "role1@example.com")
    end
  end
end