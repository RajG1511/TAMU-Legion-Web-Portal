class ResourcesController < ApplicationController
  before_action :require_exec!, only: [:dashboard, :new, :create, :edit, :update, :destroy, :toggle_publish]
  before_action :set_resource, only: [:edit, :update, :destroy, :toggle_publish]

  # Member-facing index – only show what this user can see, and only published
  def index
    scope = Resource.visible_to(current_user).published
    scope = scope.where(resource_category_id: params[:category_id]) if params[:category_id].present?
    @resources = scope.order(:created_at)
  end

  # Admin dashboard (execs only)
  def dashboard
    @resources =
      if params[:category_id].present?
        Resource.where(resource_category_id: params[:category_id])
      else
        Resource.all
      end
    @resources = @resources.order(:created_at)
    @resource_versions = ResourceVersion.includes(:resource, :user).order(created_at: :desc).limit(20)
  end

  def new
    @resource = Resource.new
    @categories = ResourceCategory.all
  end

  def create
    @resource = Resource.new(resource_params)
    if @resource.save
      log_resource_version("created")
      redirect_to dashboard_resources_path, notice: "Resource created successfully."
    else
      flash.now[:alert] = "Please fill out all required fields."
      @categories = ResourceCategory.all
      Rails.logger.debug @resource.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = ResourceCategory.all
  end

  def update
    if @resource.update(resource_params)
      log_resource_version("updated")
      redirect_to dashboard_resources_path, notice: "Resource updated successfully."
    else
      flash.now[:alert] = "Please fill out all required fields."
      @categories = ResourceCategory.all
      Rails.logger.debug @resource.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    log_resource_version("deleted")
    @resource.destroy
    redirect_to dashboard_resources_path, notice: "Resource deleted successfully."
  end

  def toggle_publish
    new_state = !@resource.published?
    @resource.update!(published: new_state)
    log_resource_version(new_state ? "published" : "unpublished")
    redirect_to dashboard_resources_path, notice: "Resource #{new_state ? 'published' : 'unpublished'} successfully."
  end

  private

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.require(:resource).permit(:name, :content, :visibility, :resource_category_id, :file, :published)
  end

  def log_resource_version(change_type)
    ResourceVersion.create!(
      resource:  @resource,
      user:      User.last, # TODO: replace with current_user when your auth is wired into this flow
      name:      @resource.name,
      content:   @resource.content,
      visibility:@resource.visibility,
      published: @resource.published,
      change_type: change_type
    )
  end
end

