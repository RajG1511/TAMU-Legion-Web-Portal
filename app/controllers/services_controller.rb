class ServicesController < ApplicationController
  # 🚨 Authorization filters disabled for now
  # before_action :authenticate_user!
  # before_action :require_submitter, only: [:new, :create, :my_services]
  # before_action :require_reviewer, only: [:index, :approve, :reject]

  # GET /services/new
  def new
    @service = Service.new
  end

  # POST /services
  def create
    # If you still want to tie to a user, uncomment the next line and make sure current_user exists
    # @service = current_user.services.build(service_params)

    # For now, just build without user association
    @service = Service.new(service_params)
    @service.status = :pending
    if @service.save
      redirect_to my_services_services_path, notice: "Service submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /services/my_services
  def my_services
    # Show all services for now, not just current_user
    @services = Service.order(created_at: :desc)
  end

  # GET /services
  def index
    # Show all services, not just pending
    @services = Service.all
  end

  # PATCH /services/:id/approve
  def approve
    service = Service.find(params[:id])
    service.update(status: :approved)
    redirect_to services_path, notice: "Service approved."
  end

  # PATCH /services/:id/reject
  def reject
    service = Service.find(params[:id])
    service.update(status: :rejected)
    redirect_to services_path, notice: "Service rejected."
  end

  private

  def service_params
    params.require(:service).permit(:name, :description, :hours, :date_performed, :user_id)
  end
end