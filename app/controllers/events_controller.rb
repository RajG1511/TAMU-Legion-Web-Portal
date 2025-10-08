class EventsController < ApplicationController
    before_action :set_event,  only: [:edit, :update, :destroy, :toggle_publish]

    # Member view index controller
    def index
    # Start with published events, optionally filtered by category
    @events = if params[:category_id].present?
                Event.where(event_category_id: params[:category_id], published: :published)
                else
                Event.where(published: :published)
                end

    # Apply role-based visibility filtering
    if user_signed_in?
        case current_user.role
        when "exec", "president"
        @events = @events.where(visibility: ["public_event", "members_only", "execs_only"])
        when "member"
        @events = @events.where(visibility: ["public_event", "members_only"])
        else
        @events = @events.where(visibility: ["public_event"])
        end
    else
        @events = @events.where(visibility: ["public_event"])
    end

    @events = @events.order(:starts_at)
    end


    # Admin view dashboard controller
    def dashboard
        if params[:category_id].present?
            @events = Event.where(event_category_id: params[:category_id]).order(:starts_at)
        else
            @events = Event.all.order(:starts_at)
        end
        
        @event_versions = EventVersion.includes(:event, :user).order(created_at: :desc).limit(20)
    end

    # New event form
    def new
        @event = Event.new
        @categories = EventCategory.all
    end

    # Create event controller | creates events and saves/logs or creates an exception
    def create
        @event = Event.new(event_params)
        
        if @event.save
            log_event_version("created")
            redirect_to dashboard_events_path, notice: "Event created successfully."
        else
            flash.now[:alert] = "Please fill out all required fields."
            @categories = EventCategory.all
            render :new, status: :unprocessable_entity
    end
  end

    # Edit event form
    def edit
        @categories = EventCategory.all
    end

    # Update event controller | updates events and saves/logs or creates an exception
    def update
        if @event.update(event_params)
            log_event_version("updated")
            redirect_to dashboard_events_path, notice: "Event updated successfully."
        else
            flash.now[:alert] = "Please fill out all required fields."
            @categories = EventCategory.all
            render :edit, status: :unprocessable_entity
        end
    end

    # Delete event controller | deletes events and logs
    def destroy
        log_event_version("deleted")
        @event.destroy
        redirect_to dashboard_events_path , notice: "Event deleted successfully."
    end

    # Toggle publish status | publishes/unpublishes events to member view and logs
    def toggle_publish
        new_state = @event.published? ? :unpublished : :published
        @event.update(published: new_state)
        log_event_version("published") if new_state == :published
        log_event_version("unpublished") if new_state == :unpublished
        redirect_to dashboard_events_path, notice: "Event #{new_state} successfully."
    end

    private

    # Set event for actions requiring an existing event
    def set_event
        @event = Event.find(params[:id])
    end

    # Strong parameters for event creation and updates
    def event_params
        params.require(:event).permit(
            :name, :description, :starts_at, :ends_at, :location_type, :campus_code, :campus_number,
            :location_name, :address, :location_text, :event_category_id, :visibility, :image
        )
    end

    # Log event version for admin to see changes
    def log_event_version(change_type)
    EventVersion.create!(
        event: @event,
        user: current_user,
        
        name: @event.name, description: @event.description,
        starts_at: @event.starts_at, ends_at: @event.ends_at,
        visibility: @event.visibility, published: @event.published,
        
        location: @event.location,
        location_type: @event.location_type,
        campus_code: @event.campus_code, campus_number: @event.campus_number,
        location_name: @event.location_name, address: @event.address,
        location_text: @event.location_text,
        
        image: @event.image,
        change_type: change_type
    )
    end

end