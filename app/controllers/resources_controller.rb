class ResourcesController < ApplicationController
    before_action :set_resource, only: [:edit, :update, :destroy, :toggle_publish]

    # Member view index controller
    def index
        scope = Resource.where(published: true)
        if params[:category_id].present?
            scope = scope.where(resource_category_id: params[:category_id])
        end
        @resources = scope.order(:created_at)
    end

    # Admin view dashboard controller
    def dashboard
        if params[:category_id].present?
            @resources = Resource.where(resource_category_id: params[:category_id])
        else
            @resources = Resource.all
        end
        @resources = @resources.order(:created_at)
        @resource_versions = ResourceVersion.includes(:resource, :user).order(created_at: :desc).limit(20)
    end

    # New resource form
    def new
        @resource = Resource.new
        @categories = ResourceCategory.all
    end

    # Create resource controller | creates resources and saves/logs or creates an exception
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

    # edit resource form
    def edit
        @categories = ResourceCategory.all
    end

    # Update resource controller | updates resources and saves/logs or creates an exception
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

    # Destroy resource controller | deletes resources and saves/logs or creates an exception
    def destroy
        log_resource_version("deleted")
        @resource.destroy
        redirect_to dashboard_resources_path, notice: "Resource deleted successfully."
    end

    # Publish/unpublish resource controller | toggles published state and saves/logs
    def toggle_publish
        new_state = !@resource.published?
        @resource.update!(published: new_state)
        log_resource_version(new_state ? "published" : "unpublished")
        redirect_to dashboard_resources_path, notice: "Resource #{new_state ? 'published' : 'unpublished'} successfully."
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
        @resource = Resource.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def resource_params
        params.require(:resource).permit(:name, :content, :visibility, :resource_category_id, :file)
     end

    # Log resource version changes
     def log_resource_version(change_type)
        ResourceVersion.create!(
            resource: @resource,
            user: User.last, # temp
            name: @resource.name,
            content: @resource.content,
            visibility: @resource.visibility,
            published: @resource.published,
            change_type: change_type
        )
    end
end