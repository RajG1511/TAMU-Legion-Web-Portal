class ServicesController < ApplicationController
  #skip_before_action :authenticate_user!   # must be logged in for all actions

  def index
    # Show all service requests to everyone
    if params[:user_id]
      @services = Service.where(user_id: params[:user_id])
    else
      @services = Service.all
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
end