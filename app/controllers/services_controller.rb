class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_exec_or_president, only: [:approve, :reject, :dashboard]

  def index
    if current_user.exec? || current_user.president?
      @services = Service.order(date_performed: :desc).page(params[:page]).per(10)
    else
      @services = current_user.services.order(date_performed: :desc).page(params[:page]).per(10)
    end
  end

  def dashboard
    # Pending requests for the right-hand column
    @services = Service.pending.recent

    # All requests (approved, rejected, pending) for the log on the left
    @all_services = Service.includes(:user).order(created_at: :desc)

    # Totals of approved hours grouped by committee
    @committee_totals = Service.approved
                               .group(:committee)
                               .sum(:hours)
  end

  def my_services
    @services = current_user.services.order(date_performed: :desc).page(params[:page]).per(10)
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
    params.require(:service).permit(:name, :description, :hours, :date_performed, :committee)
  end

  def require_exec_or_president
    unless current_user&.exec? || current_user&.president?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end