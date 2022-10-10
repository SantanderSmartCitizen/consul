class Admin::ManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @managers = @managers.page(params[:page])
  end

  def search
    @users = User.employees.search(params[:name_or_email])
                 .includes(:manager)
                 .page(params[:page])
                 .for_render
  end

  def create
    @manager = Manager.new(manager_params)
    @manager.save!

    notice = t("admin.managers.form.created")
    redirect_to edit_admin_manager_path(@manager), notice: notice
  end

  def edit
    @manager = Manager.find(params[:id])
    @management_areas = ManagementArea.all
  end

  def update
    @manager = Manager.find(params[:id])
    if @manager.update(manager_params)
      notice = t("admin.managers.form.updated")
      redirect_to admin_managers_path, notice: notice
    else
      render :edit
    end
  end

  def destroy
    @manager.destroy!
    redirect_to admin_managers_path
  end

  private

    def manager_params
      params.require(:manager).permit(:user_id, :management_area_id)
    end

end
