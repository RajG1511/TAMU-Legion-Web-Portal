class CommitteeMembershipsController < ApplicationController
     before_action :require_exec!
  before_action :set_committee

  def create
       user = User.find(params[:user_id])
    if @committee.committee_memberships.create!(user: user)
         flash[:success] = "User #{user.full_name} added to committee #{@committee.name}."
      redirect_to committee_path(@committee)
    else
         flash[:error] = "User #{user.full_name} not added to committee #{@committee.name}."
      redirect_to committee_path(@committee)
    end
  end

  def destroy
       user = User.find(params[:user_id])
    @committee.committee_memberships.destroy_by(user: user)
    flash[:success] = "User #{user.full_name} removed from committee #{@committee.name}."
    redirect_to committee_path(@committee)
  end

  private
       def set_committee
            @committee = Committee.find(params[:committee_id])
       end
end
