class UsersController < ApplicationController
  before_action :require_exec!, only: [:index, :show, :new, :create, :edit, :update, :delete, :destroy, :bulk_edit, :bulk_update, :reset_inactive]
  before_action :set_user,      only: [:show, :edit, :update, :delete, :destroy]

  def public_index
    @execs = User.where(role: "exec").order(:last_name, :first_name)
    @committees = Committee.all.includes(committee_memberships: :user).order(:name)
  end

  # index with safe search + total hours for the grid
  def index
    scope = User.left_joins(:services)
      .select('users.*, COALESCE(SUM(CASE WHEN services.status = 1 THEN services.hours END), 0) AS total_hours')
      .group('users.id')
      .order(:last_name, :first_name)

    scope = scope.merge(User.search(params[:q])) if params[:q].present?
    @users = scope

    # log list
    @user_versions = UserVersion.includes(:actor, :user).order(created_at: :desc).limit(50)
  end

  def show
    # service hours rollup and list
    @approved_hours = @user.services.approved.sum(:hours)
    @services = @user.services.recent
  end

  def new
    @user = User.new(role: :member, status: :active)
  end

  def create
    defaults = {}
    defaults[:role]   = :member if params.dig(:user, :role).blank?
    defaults[:status] = :active if params.dig(:user, :status).blank?

    @user = User.new(defaults.merge(user_params))
    if @user.save
      log_user_change(@user, :created, summary: "Member created")
      flash[:success] = "User created."
      redirect_to users_path
    else
      Rails.logger.error(@user.errors.full_messages.to_sentence)
      flash.now[:error] = "User not created: " + @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    before = @user.attributes.slice(*mutable_keys)
    if @user.update(user_params)
      after = @user.attributes.slice(*mutable_keys)
      log_user_change(@user, :updated, summary: "Member updated", diff: changed_diff(before, after))
      flash[:success] = "User updated."
      redirect_to users_path
    else
      flash.now[:error] = "User not updated: " + @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def delete; end

  def destroy
    name = @user.full_name
    if @user.destroy
      log_user_change(@user, :deleted, summary: "Member deleted (#{name})")
      flash[:success] = "User deleted."
    else
      # typically blocked by dependent: :restrict_with_error (to preserve logs)
      flash[:error] = @user.errors.full_messages.to_sentence.presence || "Cannot delete this user because there are audit log references."
    end
    redirect_to users_path
  end

  # ---------- BULK ACTIONS ----------
  def bulk_edit
    @users = User.where(id: params[:user_ids])
    redirect_to(users_path, alert: "Please select users to edit") if @users.empty?
  end

  def bulk_update
    user_ids = Array(params[:user_ids])
    updates  = {}

    [:status, :graduation_year, :major, :t_shirt_size].each do |field|
      value = params.dig(:bulk_update, field)
      updates[field] = value if value.present?
    end

    if updates.any? && user_ids.any?
      User.where(id: user_ids).update_all(updates)
      UserVersion.create!(
        user: current_user, actor: current_user,
        change_type: :bulk_updated,
        change_summary: "Bulk updated #{user_ids.size} members",
        diff: updates
      )
      flash[:success] = "#{user_ids.count} users updated successfully"
    else
      flash[:alert] = "No fields selected for update"
    end
    redirect_to users_path
  end

  def reset_inactive
    count = User.inactive.update_all(status: :active)
    UserVersion.create!(
      user: current_user, actor: current_user,
      change_type: :reset_inactive,
      change_summary: "Reset #{count} inactive members to active",
      diff: {}
    )
    flash[:success] = "Reset #{count} inactive members to active status"
    redirect_to users_path
  end

  def update_member_center_caption
    text = params[:text]
    allowed_tags = %w[a]
    allowed_attributes = %w[href title target]
    sanitized_text = ActionController::Base.helpers.sanitize(text, tags: allowed_tags, attributes: allowed_attributes)

    if sanitized_text.blank?
      redirect_back(fallback_location: root_path, alert: "Caption cannot be empty!")
      return
    end

    File.write(Rails.root.join("config", "member_center_caption.yml"), { text: sanitized_text }.to_yaml)
    redirect_back(fallback_location: root_path, notice: "Member Center Caption updated!")
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def mutable_keys
    %w[email first_name last_name graduation_year major t_shirt_size image_url headshot status position role]
  end

  def changed_diff(before, after)
    diff = {}
    after.each { |k,v| diff[k] = { before: before[k], after: v } if before[k] != v }
    diff
  end

  def log_user_change(user, type, summary:, diff: {})
    UserVersion.create!(user: user, actor: current_user, change_type: type, change_summary: summary, diff: diff)
  rescue => e
    Rails.logger.warn "UserVersion log failed: #{e.message}"
  end

  # ----- strong params -----
  def base_permitted_params
    [:email, :first_name, :last_name, :graduation_year, :major, :t_shirt_size, :image_url, :headshot, :position]
  end

  def exec_permitted_params
    base_permitted_params + [:status]
  end

  def pres_permitted_params
    exec_permitted_params + [:role]
  end

  def create_permitted_params
    [] # password fields are hidden/managed in model
  end

  def user_params
    permitted_params =
      if current_user&.president?
        pres_permitted_params
      elsif current_user&.exec?
        exec_permitted_params
      else
        base_permitted_params
      end

    permitted_params += create_permitted_params if action_name == "create"
    params.require(:user).permit(permitted_params)
  end
end

