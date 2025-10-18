class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_exec_or_president, only: [:approve, :reject, :dashboard]

  def index
    # Members see only their own requests; execs/president see all
    if current_user.exec? || current_user.president?
      @services = Service.all.recent
    else
      @services = current_user.services.recent
    end
  end

  def dashboard
    # Execs/president see all pending requests
    @services = Service.pending.recent
  end

  def new
    @service = Service.new
  end

  def create
    @service = current_user.services.build(service_params)
    if @service.save
      redirect_to services_path, notice: "Service request submitted."
    else
      flash[:error] = "Service request not created: " + @service.errors.full_messages.to_sentence
      render :new
    end
  end

  def approve
    @service = Service.find(params[:id])
    @service.update(status: :approved)
    redirect_to dashboard_services_path, notice: "Service approved."
  end

  def reject
    @service = Service.find(params[:id])
    if @service.update(status: :rejected, rejection_reason: params[:service][:rejection_reason])
      redirect_to dashboard_services_path, alert: "Service rejected."
    else
      redirect_to dashboard_services_path, alert: "Rejection failed: #{@service.errors.full_messages.to_sentence}"
    end
  end

  private


  def service_params
    params.require(:service).permit(:name, :description, :hours, :date_performed, :status, :rejection_reason)
  end

  def require_exec_or_president
    unless current_user&.exec? || current_user&.president?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end