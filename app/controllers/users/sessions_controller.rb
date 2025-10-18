module Users
  class SessionsController < Devise::SessionsController
    def after_sign_in_path_for(_resource_or_scope)
      stored_location_for(_resource_or_scope) || login_path
    end
    
    def after_sign_out_path_for(_resource_or_scope)
      login_path
    end
  end
end
