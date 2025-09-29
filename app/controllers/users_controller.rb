class UsersController < ApplicationController
  # For now, no authorization checks
  # before_action :authenticate_user!
  def index
    @users = User.all.order(:first_name, :last_name)
  end

  def show
    @user = User.find(params[:id])
  end
end