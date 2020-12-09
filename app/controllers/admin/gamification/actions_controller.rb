class Admin::Gamification::ActionsController < Admin::Gamification::BaseController
  include Translatable

  before_action :load_action, only: [:show, :edit, :update]

  load_and_authorize_resource :gamification
  load_and_authorize_resource :action, class: "Gamification::Action"

  def index
  end

  def new
    @gamifications = Gamification.all
  end

  def create
    @action = ::Gamification::Action.new(action_params)
    @gamification = @action.gamification

    if @action.save
      redirect_to admin_gamification_path(@gamification),
               notice: t("flash.actions.create.gamification_action")
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @action.update(action_params)
      redirect_to admin_gamification_path(@action.gamification), notice: t("flash.actions.update.gamification_action")
    else
      render :edit
    end
  end

  def destroy
  end

  private

    def action_params
      attributes = [:gamification_id, :key, :score]
      params.require(:gamification_action).permit(
        *attributes, translation_params(Gamification::Action)
      )
    end

    def load_action
      @action = ::Gamification::Action.find(params[:id] || params[:action_id])
    end

    def resource
      load_action unless @action
      @action
    end

end
