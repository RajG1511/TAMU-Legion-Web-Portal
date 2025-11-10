class ApplicationController < ActionController::Base
     allow_browser versions: :modern
     before_action :load_nav_committees

  def require_member!
       return if current_user&.member?
    redirect_to login_path, alert: "Please sign in to continue."
  end

  def require_exec!
       return if current_user&.exec?
    redirect_to login_path, alert: "Please sign in as an executive to continue."
  end

  def require_president!
       return if current_user&.president?
    redirect_to login_path, alert: "Please sign in as president to continue."
  end

  def after_sign_in_path_for(resource)
       member_center_path
  end

  private

       def load_nav_committees
            @nav_committees = Committee.select(:id, :name).order(:name)
       end
end
