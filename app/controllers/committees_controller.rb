class CommitteesController < ApplicationController
  before_action :require_exec!, except: [ :index, :show ]
  before_action :set_committee, only: [ :show, :edit, :update, :delete, :destroy ]

  def index
    @committees = Committee.include(:committee_memberships).order(:name)
  end

  def show
  end

  def new
    @committee = Committee.new
  end

  def create
    @committee = Committee.new(committee_params)
    if @committee.save
      log_committee_version("created")
      flash[:success] = "Committee #{@committee.name} created."
      redirect_to committee_path(@committee)
    else
      flash[:error] = "Committee not created."
      render :new
    end
  end

  def edit
  end

  def update
    if @committee.update(committee_params)
      log_committee_version("updated")
      flash[:success] = "Committee #{@committee.name} updated."
      redirect_to committee_path(@committee)
    else
      flash[:error] = "Committee not updated."
      render :edit
    end
  end

  def delete
  end

  def destroy
    @committee.destroy
    log_committee_version("deleted")
    flash[:success] = "Committee #{@committee.name} deleted."
    redirect_to committees_path
  end

  private

  def set_committee
    @committee = Committee.find(params[:id]).include(:committee_memberships)
  end

  def committee_params
    params.require(:committee).permit(:name, :description)
  end

  def log_committee_version(change_type)
    CommitteeVersion.create!(
        committee: @committee,
        user: User.last,

        name: @committee.name,
        description: @committee.description,
        change_type: change_type
    )
  end
end
