class ServicesController < ApplicationController
  before_action :authenticate_user!   # must be logged in for all actions
  before_action :require_exec!, only: [:approve, :reject]

  def index
    # Everyone can see their own requests
    if params[:user_id]
      @services = Service.where(user_id: params[:user_id])
    # Execs/President can see all
    elsif current_user.exec? || current_user.president?
      @services = Service.all
    else
      @services = current_user.services
    end
  end

  def new
    @service = Service.new
  end

  def create
    @service = current_user.services.build(service_params)
    if @service.save
      flash[:success] = "Service request submitted."
      redirect_to services_path(user_id: current_user.id)
    else
      flash[:error] = "Service request not created: " + @service.errors.full_messages.to_sentence
      render :new
    end
  end

  def approve
    @service = Service.find(params[:id])
    @service.update(status: "approved")
    redirect_to services_path, notice: "Service approved."
  end

  def reject
    @service = Service.find(params[:id])
    @service.update(status: "rejected")
    redirect_to services_path, alert: "Service rejected."
  end

  private

  def service_params
    params.require(:service).permit(:description, :hours, :status)
  end

  def require_exec!
    unless current_user.exec? || current_user.president?
      redirect_to root_path, alert: "Not authorized."
    end
  end
end