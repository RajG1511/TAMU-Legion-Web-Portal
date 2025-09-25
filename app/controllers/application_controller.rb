class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # May be repetition of user model, I will have to see which approach is better.
  def current_role_level
    current_user&.role || 0
  end

  def require_member!
    return if current_role_level >= 1
    redirect_to new_user_session_path, alert: 'Member access only.'
  end

  def require_exec!
    return if current_role_level >= 2
    redirect_to new_user_session_path, alert: 'Execuitive access only.'
  end

  def require_president!
    return if current_role_level >= 3
    redirect_to new_user_session_path, alert: 'President access only.'
  end
end
