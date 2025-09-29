class UsersController < ApplicationController
  # Restrict access: only execs (and president) can manage users
  # For now, allow anyone to view/manage users by commenting this out
  # before_action :require_exec!, only: [:index, :show, :new, :create, :edit, :update, :delete, :destroy]

  before_action :set_user, only: [:show, :edit, :update, :delete, :destroy]

  def index
    @users = User.all.order(:first_name, :last_name)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "User created."
      redirect_to users_path
    else
      flash[:error] = "User not created."
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "User updated."
      redirect_to users_path
    else
      flash[:error] = "User not updated."
      render :edit
    end
  end

  def delete
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted."
    redirect_to users_path
  end

  private

  # --- Strong params ---
  def base_permitted_params
    [:email, :first_name, :last_name, :graduation_year, :major, :t_shirt_size, :image_url]
  end

  def exec_permitted_params
    base_permitted_params + [:status]
  end

  def pres_permitted_params
    exec_permitted_params + [:position, :role]
  end

  def user_params
    if current_user&.president?
      params.require(:user).permit(pres_permitted_params)
    elsif current_user&.exec?
      params.require(:user).permit(exec_permitted_params)
    else
      params.require(:user).permit(base_permitted_params)
    end
  end

  # --- Callbacks ---
  def set_user
    @user = User.find(params[:id])
  end

  # --- Authorization (currently disabled) ---
  def require_exec!
    return if current_user&.exec? || current_user&.president?
    redirect_to root_path, alert: "Executive access only."
    # Or, if you prefer to force login:
    # redirect_to user_google_oauth2_omniauth_authorize_path, alert: "Please sign in as an exec."
  end
end