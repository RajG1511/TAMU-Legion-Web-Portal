class CommitteesController < ApplicationController
     before_action :require_exec!, only: [ :dashboard, :new, :create, :edit, :update, :delete, :destroy ]
     before_action :set_committee, only: [ :show, :edit, :update, :delete, :destroy ]

     def index
          @committees = Committee.order(:name)
     end

     def show
     end

     def dashboard
          @committees = Committee.includes(:active_users).order(:name)
          @committee_versions = CommitteeVersion.includes(:committee, :user).order(created_at: :desc).limit(20)
     end

     def new
          @committee = Committee.new
     end

     def create
          @committee = Committee.new(committee_params)
     if @committee.save
          log_committee_version("created")
          flash[:success] = "Committee #{@committee.name} created."
          redirect_to dashboard_committees_path
     else
          flash[:error] = "Committee not created."
          render :new
     end
     end

     def edit
          load_members_for_form
     end

     def update
          if @committee.update(committee_params)
               log_committee_version("updated")
          flash[:success] = "Committee #{@committee.name} updated."
          redirect_to dashboard_committees_path
          else
               flash[:error] = "Committee not updated."
          render :edit
          end
     end

     def delete
     end


     # TODO: This will get rid of the version logs, if logs need to be kept, change this
     def destroy
          @committee.destroy
     # log_committee_version("deleted")
     flash[:success] = "Committee #{@committee.name} deleted."
     redirect_to dashboard_committees_path
     end

     private

          def set_committee
               @committee = Committee.includes(:active_users).find(params[:id])
          end

     def committee_params
          params.require(:committee).permit(
          :name,
          :description,
          :section1_heading,
          :section1_body,
          :section2_heading,
          :section2_body,
          :primary_image,
          :secondary_image
          )
     end


     def log_committee_version(change_type)
          CommitteeVersion.create!(
               committee: @committee,
               user: current_user,

               name: @committee.name,
               description: @committee.description,
               change_type: change_type
          )
     end

     def load_members_for_form
          @members = @committee&.active_users || User.none
          @non_members = User.active.where.not(id: @members.select(:id)).order(:last_name, :first_name)
     end
end
