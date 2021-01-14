class Admin::Gamification::ActionsController < Admin::Gamification::BaseController
  include Translatable

  before_action :load_action, only: [:show, :edit, :update, :search]
  before_action :load_search, only: [:search]

  load_and_authorize_resource :gamification
  load_and_authorize_resource :action, class: "Gamification::Action"

  def index
    @actions = ::Gamification::Action.all
  end

  def new
  end

  def create
    @action = ::Gamification::Action.new(action_params)

    if @action.save
      if params[:gamification_action][:return_to] == "gamification"
        return_path = admin_gamification_path(@action.gamification)
      else
        return_path = admin_gamification_actions_path()
      end
      redirect_to return_path, notice: t("flash.actions.create.gamification_action")
    else
      render :new
    end
  end

  def show
    @gamification_action_additional_scores = Kaminari.paginate_array(@action.gamification_action_additional_scores).page(params[:page]).per(5)
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

  def update_operations
    process_type = params[:process_type]
    if process_type.present?
        @operations = helpers.get_operation_select_options(process_type)
    else
        @operations = Array(nil)
    end
    if request.xhr?
        respond_to do |format|
            format.json {
                render json: {operations: @operations}
            }
        end
    end
  end

  def search
    case @action.process_type
      when "debate"
        model = Debate
      when "proposal"
        model = Proposal
      when "poll"
        model = Poll
      when "process"
        model = ::Legislation::Process
      when "forum"
        model = Forum
    end
    @processes = @search.present? ? model.search(@search) : model.all
    @processes = @processes.order(created_at: :desc).page(params[:page])
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

    def load_search
      @search = params.permit(:search)[:search]
    end

end
