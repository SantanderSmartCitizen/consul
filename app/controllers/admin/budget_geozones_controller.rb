class Admin::BudgetGeozonesController < Admin::BaseController
  respond_to :html

  load_and_authorize_resource

  def index
    @budget_geozones = BudgetGeozone.all.order("LOWER(name)")
  end

  def new
  end

  def edit
  end

  def create
    @budget_geozone = BudgetGeozone.new(budget_geozone_params)

    if @budget_geozone.save
      redirect_to admin_budget_geozones_path
    else
      render :new
    end
  end

  def update
    if @budget_geozone.update(budget_geozone_params)
      redirect_to admin_budget_geozones_path
    else
      render :edit
    end
  end

  def destroy
    #if @budget_geozone.safe_to_destroy?
      @budget_geozone.destroy!
      redirect_to admin_budget_geozones_path, notice: t("admin.budget_geozones.delete.success")
    #else
    #  redirect_to admin_budget_geozones_path, flash: { error: t("admin.budget_geozones.delete.error") }
    #end
  end

  private

    def budget_geozone_params
      params.require(:budget_geozone).permit(:name, :external_code)
    end
end
