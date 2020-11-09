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
      redirect_to [:admin, @gamification], notice: t("flash.actions.update.gamification")
    else
      render :edit
    end
  end

  def destroy
=begin
    if ::Poll::Voter.where(poll: @poll).any?
      redirect_to admin_poll_path(@poll), alert: t("admin.polls.destroy.unable_notice")
    else
      @poll.destroy!

      redirect_to admin_polls_path, notice: t("admin.polls.destroy.success_notice")
    end
=end
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
