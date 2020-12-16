class Admin::Gamification::ActionsController < Admin::Gamification::BaseController
  include Translatable

  before_action :load_action, only: [:show, :edit, :update]

  load_and_authorize_resource :gamification
  load_and_authorize_resource :action, class: "Gamification::Action"

  def index
    @actions = ::Gamification::Action.all
  end

  def new
    @gamifications = Gamification.all
  end

  def create
    @action = ::Gamification::Action.new(action_params)
    @gamification = @action.gamification

    if @action.save
      if params[:gamification_action][:return_to] == "gamification"
        return_path = admin_gamification_path(@gamification)
      else
        return_path = admin_gamification_actions_path()
      end
      redirect_to return_path, notice: t("flash.actions.create.gamification_action")
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
      if params[:gamification_action][:return_to] == "gamification"
        return_path = admin_gamification_path(@action.gamification)
      else
        return_path = admin_gamification_actions_path()
      end
      redirect_to return_path, notice: t("flash.actions.update.gamification_action")
    else
      render :edit
    end
  end

  def destroy
  end

  private

    def action_params
      attributes = [:gamification_id, :key, :process_type, :operation, :score]
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
