class UsersController < ApplicationController
  # will be exec only for now
  # will want to allow users to view themselves later
  # may want a directory for members to view, depends on what the customer wants
  before_action :require_exec!, only: [:index, :show, :new, :create, :edit, :update, :delete, :destroy]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.active_storage_overview
      flash[:success] = "User created."
      redirect to users_path
    else
      flash[:error] = "User not created."
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "User updated."
      redirect to users_path
    else
      flash[:error] = "User not updated."
      render :edit
    end
  end

  def delete
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "User deleted."
    redirect to users_path
  end

  private

  def base_permitted_params
    [:email, :first_name, :last_name, :graduation_year, :major, :t_shirt_size, :image_url]
  end

  def exec_permitted_params
    base_permitted_params + [:status, :position, :role]
  end

  def user_params
    if current_user&.exec?
      params.require(:user).permit(exec_permitted_params)
    else
      params.require(:user).permit(base_permitted_params)
    end
  end
end