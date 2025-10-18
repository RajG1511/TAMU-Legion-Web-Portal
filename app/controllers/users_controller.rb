class UsersController < ApplicationController

  # execs only for now
  before_action :require_exec!, only: [:index, :show, :new, :create, :edit, :update, :delete, :destroy]
  before_action :set_user,      only: [:show, :edit, :update, :delete, :destroy]

  def index
    @users = User.all
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "User created."
      redirect_to users_path
    else
      flash.now[:error] = "User not created."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = "User updated."
      redirect_to users_path
    else
      flash.now[:error] = "User not updated."
      render :edit, status: :unprocessable_entity
    end
  end

  def delete; end

  def destroy
    @user.destroy
    flash[:success] = "User deleted."
    redirect_to users_path
  end

  # ---------- BULK ACTIONS ----------
  def bulk_edit
    @users = User.where(id: params[:user_ids])
    redirect_to(users_path, alert: "Please select users to edit") if @users.empty?
  end

  def bulk_update
    user_ids = params[:user_ids] || []
    updates  = {}

    [:status, :graduation_year, :major, :t_shirt_size].each do |field|
      value = params.dig(:bulk_update, field)
      updates[field] = value if value.present?
    end

    if updates.any?
      User.where(id: user_ids).update_all(updates)
      flash[:success] = "#{user_ids.count} users updated successfully"
    else
      flash[:alert] = "No fields selected for update"
    end

    redirect_to users_path
  end

  def reset_inactive
    inactive_count = User.inactive.update_all(status: :active)
    flash[:success] = "Reset #{inactive_count} inactive members to active status"
    redirect_to users_path
  end

    # app/controllers/users_controller.rb
    def update_member_center_caption
      text = params[:text]
      File.write(Rails.root.join("config", "member_center_caption.yml"), { text: text }.to_yaml)
      redirect_back(fallback_location: root_path, notice: "Member Center Caption updated!")
    end



  # ----------------------------------

  private

  def set_user
    @user = User.find(params[:id])
  end

  # base fields everyone can edit

  def base_permitted_params
    [:email, :first_name, :last_name, :graduation_year, :major, :t_shirt_size, :image_url]
  end

  # execs can also set status

  def exec_permitted_params
    base_permitted_params + [:status]
  end


  # president can also set position/role

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
end

