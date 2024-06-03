class ComplaintsController  < ApplicationController

  load_and_authorize_resource only: [:index]
  respond_to :html, :js

  def index
    @user_complaints = Complaint.where(user_id: current_user.id).order(created_at: :desc).page(params[:page])
  end

end
