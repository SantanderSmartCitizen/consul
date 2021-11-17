class Admin::Gamification::GamificationsController < Admin::Gamification::BaseController
  include Translatable
  include ReportAttributes
  
  load_and_authorize_resource
  

  def index
    @gamifications = Gamification.order(id: :asc).page(params[:page])
  end

  def show
    @gamification = Gamification.find(params[:id])
  end

  def new
  end

  def create
	  @gamification = Gamification.new(gamification_params)
    if @gamification.save
      notice = t("flash.actions.create.gamification")
      redirect_to [:admin, @gamification], notice: notice
    else
      render :new
    end
  end

  def edit
  end

  def update 	
    if @gamification.update(gamification_params)
      notice = t("flash.actions.update.gamification")
      redirect_to [:admin, @gamification], notice: notice
    else
      render :edit
    end
  end

  def destroy
    if @gamification.destroy
      flash[:notice] = t("flash.actions.destroy.gamification")
    else
      flash[:error] = @gamification.errors.full_messages.join(",")
    end

    redirect_to admin_gamifications_path
  end

  def results
  end

  def add_action
    action = ::Gamification::Action.find(params[:action_id])

    if action.present?
      @gamification.actions << action
      notice = t("admin.gamifications.flash.action_added")
    else
      notice = t("admin.gamifications.flash.error_on_action_added")
    end
    redirect_to admin_gamification_path(@gamification), notice: notice
  end

  private

    def gamification_params
      attributes = [:key]
      params.require(:gamification).permit(*attributes, translation_params(Gamification))
    end

    def resource
      @gamification ||= Gamification.find(params[:id])
    end

end
