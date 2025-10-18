<<<<<<< HEAD
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
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
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
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

  def after_sign_in_path_for(resource)
    member_center_path
  end
end
>>>>>>> origin/test
