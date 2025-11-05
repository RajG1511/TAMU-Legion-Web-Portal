class UsersController < ApplicationController
  before_action :require_exec!, only: %i[index show new create edit update delete destroy bulk_edit bulk_update reset_inactive]
  before_action :set_user,      only: %i[show edit update delete destroy]

  # PUBLIC MEMBERS (unchanged)
  def public_index
    @execs      = User.where(role: "exec").order(:last_name, :first_name)
    @committees = Committee.all.includes(committee_memberships: :user).order(:name)
  end

  # DASHBOARD (styled like Resources dashboard)
  def index
    @q = params[:q].to_s.strip
    base = User.includes(:services)

    if @q.present?
      like = "%#{@q}%"
      text = base.where(<<~SQL, q: like)
        first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR
        position ILIKE :q OR major ILIKE :q OR CAST(graduation_year AS TEXT) ILIKE :q
      SQL
      role_hits   = User.roles.keys.select   { |r| r.include?(@q.downcase) }
      status_hits = User.statuses.keys.select{ |s| s.include?(@q.downcase) }
      role_match   = role_hits.any?   ? base.where(role: role_hits)     : base.none
      status_match = status_hits.any? ? base.where(status: status_hits) : base.none
      @users = text.or(role_match).or(status_match).order(:last_name, :first_name)
    else
      @users = base.order(:last_name, :first_name)
    end

    @user_versions = UserVersion.includes(:user, :target_user).order(created_at: :desc).limit(40)
  end

  def show
    @services       = @user.services.order(date_performed: :desc)
    @approved_hours = @user.services.approved.sum(:hours)
  end

  def new
    @user = User.new(role: :member, status: :active)
  end

  def create
    shared_pwd = ENV["SHARED_USER_PASSWORD"].presence || Rails.application.credentials.dig(:shared_user_password)
    raise "Missing SHARED_USER_PASSWORD" if shared_pwd.blank?

    attrs = user_params.merge(password: shared_pwd, password_confirmation: shared_pwd)
    if (@user = User.new(attrs)).save
      log_user_change(:created, @user, "Created #{@user.full_name}")
      redirect_to users_path, notice: "User created."
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      @user.headshot.purge if params.dig(:user, :remove_headshot) == "1"
      log_user_change(:updated, @user, "Updated #{@user.full_name}", details: @user.previous_changes.except(:updated_at))
      redirect_to users_path, notice: "User updated."
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def delete; end

  def destroy
    name = @user.full_name
    @user.destroy
    log_user_change(:deleted, @user, "Deleted #{name}")
    redirect_to users_path, notice: "User deleted."
  end

  # -------- BULK --------
  def bulk_edit
    @users = User.where(id: params[:user_ids])
    redirect_to(users_path, alert: "Please select users to edit") if @users.empty?
  end

  def bulk_update
    user_ids = Array(params[:user_ids])
    updates  = %i[status graduation_year major t_shirt_size].each_with_object({}) do |field, h|
      v = params.dig(:bulk_update, field)
      h[field] = v if v.present?
    end
    if updates.any?
      User.where(id: user_ids).update_all(updates)
      log_user_change(:bulk_updated, current_user, "Bulk updated #{user_ids.count} users",
                      details: { user_ids: user_ids, updates: updates })
      redirect_to users_path, notice: "#{user_ids.count} users updated."
    else
      redirect_to users_path, alert: "No fields selected for update"
    end
  end

  def reset_inactive
    n = User.inactive.update_all(status: :active)
    log_user_change(:reset_inactive, current_user, "Reset #{n} inactive users to active", details: { count: n })
    redirect_to users_path, notice: "Reset #{n} users."
  end

  def update_member_center_caption
    text = params[:text]
    allowed_tags = %w[a]; allowed_attrs = %w[href title target]
    safe = helpers.sanitize(text, tags: allowed_tags, attributes: allowed_attrs)
    return redirect_back(fallback_location: root_path, alert: "Caption cannot be empty!") if safe.blank?
    File.write(Rails.root.join("config", "member_center_caption.yml"), { text: safe }.to_yaml)
    redirect_back(fallback_location: root_path, notice: "Member Center Caption updated!")
  end

  private

  def set_user; @user = User.find(params[:id]); end

  # same field philosophy as mockup: execs can set status; president can set role
  def base_permitted_params
    %i[email first_name last_name graduation_year major t_shirt_size image_url headshot position]
  end
  def exec_permitted_params  ; base_permitted_params + %i[status]                   ; end
  def pres_permitted_params  ; exec_permitted_params + %i[role]                     ; end
  def user_params
    permitted =
      if current_user&.president? then pres_permitted_params
      elsif current_user&.exec?   then exec_permitted_params
      else base_permitted_params end
    params.require(:user).permit(permitted)
  end

  def log_user_change(type, target, summary, details: {})
    UserVersion.create!(user: current_user, target_user: target, change_type: type, summary: summary, details: details)
  end
end

