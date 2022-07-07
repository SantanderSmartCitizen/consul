class Admin::EmployeesController < Admin::BaseController
  load_and_authorize_resource :user

  def index
    @employees = User.employees.by_username_email_or_document_number(params[:search]).page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
