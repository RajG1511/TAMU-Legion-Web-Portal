class ResourcesController < ApplicationController
     before_action :require_exec!, only: [ :dashboard, :new, :create, :edit, :update, :destroy, :toggle_publish ]
  before_action :set_resource, only: [ :edit, :update, :destroy, :toggle_publish ]

  # Member view index
  def index
       @resources = Resource.published
    @resources = @resources.where(resource_category_id: params[:category_id]) if params[:category_id].present?

    # Apply role-based visibility filtering
    if user_signed_in?
         case current_user.role
         when "exec", "president"
              @resources = @resources.where(visibility: [ "public_resource", "members_only", "execs_only" ])
         when "member"
              @resources = @resources.where(visibility: [ "public_resource", "members_only" ])
         else
              @resources = @resources.where(visibility: [ "public_resource" ])
         end
    else
         @resources = @resources.where(visibility: [ "public_resource" ])
    end

    @resources = @resources.order(:created_at)
  end

  # Admin dashboard (execs only)
  def dashboard
       @resources = Resource.all
    @resources = @resources.where(resource_category_id: params[:category_id]) if params[:category_id].present?
    @resources = @resources.where(visibility: params[:visibility]) if params[:visibility].present?
    @resources = @resources.order(:created_at)
    @resource_versions = ResourceVersion.includes(:resource, :user).order(created_at: :desc).limit(20)
  end


  def new
       @resource = Resource.new
    @categories = ResourceCategory.all
  end

  # Create a new resource
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

  # Update an existing resource
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

  # Delete a resource
  def destroy
       log_resource_version("deleted")
    @resource.destroy
    redirect_to dashboard_resources_path, notice: "Resource deleted successfully."
  end

  # Toggle publish/unpublish state
  def toggle_publish
       new_state = @resource.published == "published" ? :unpublished : :published
    @resource.update!(published: new_state)
    log_resource_version(new_state.to_s)
    redirect_to dashboard_resources_path, notice: "Resource #{new_state} successfully."
  end


  private

       # Set resource for actions requiring an existing resource
       def set_resource
            @resource = Resource.find(params[:id])
       end

  # Strong parameters for resource
  def resource_params
       params.require(:resource).permit(:name, :content, :visibility, :resource_category_id, :file, :published, :resource_type)
  end

  # Log changes to resource versions
  def log_resource_version(change_type)
       ResourceVersion.create!(
         resource:  @resource,
         user:      current_user,
         name:      @resource.name,
         content:   @resource.content,
         visibility: @resource.visibility,
         published: @resource.published,
         resource_type: @resource.resource_type,
         change_type: change_type
       )
  end
end
