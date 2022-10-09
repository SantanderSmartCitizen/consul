class Admin::EmployeesController < Admin::BaseController
  load_and_authorize_resource param_method: :user_params, class: "User"

  def index
    @employees = User.employees.by_username_email_or_document_number(params[:search]).page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
  end

  def create
    @employee.password = SecureRandom.base58(24)
    @employee.created_from_signature = true
    @employee.confirmed_at = Time.current
    @employee.verified_at = Time.current
    @employee.terms_of_service = true
    @employee.locale = "es"

    if @employee.save
		notice = t("admin.employees.notice.create")
    	redirect_to admin_employees_path, notice: notice
    else
    	render :new
    end
  end

  def edit
  end

  def update 	
    if @employee.update(user_params)
      notice = t("admin.employees.notice.update")
      redirect_to admin_employees_path, notice: notice
    else
      render :edit
    end
  end

  def destroy
  	email = Time.current.strftime("%Y%m%d%H%M%S")+"-"+@employee.email
    if @employee.update(email: email) && @employee.destroy
      flash[:notice] = t("admin.employees.notice.destroy.success")
    else
      flash[:error] = @employee.errors.full_messages.join(",")
    end

    redirect_to admin_employees_path
  end

  private

    def user_params
      attributes = [:username, :email]
      params.require(:user).permit(*attributes)
    end

    def resource
      @employee ||= User.employee.find(params[:id])
    end

end
