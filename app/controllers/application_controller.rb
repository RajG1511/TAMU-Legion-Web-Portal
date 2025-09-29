class ApplicationController < ActionController::Base
  allow_browser versions: :modern
<<<<<<< HEAD
  
  def require_member!
    return if current_user&.member?
    redirect_to new_user_session_path, alert: 'Member access only.'
  end

  def require_exec!
    return if current_user&.exec?
    redirect_to new_user_session_path, alert: 'Executive access only.'
  end

  def require_president!
    return if current_user&.president?
    redirect_to new_user_session_path, alert: 'President access only.'
  end
end
=======
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
>>>>>>> origin/test-david
