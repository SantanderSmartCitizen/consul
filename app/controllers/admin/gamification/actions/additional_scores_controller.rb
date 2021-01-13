class Admin::Gamification::Actions::AdditionalScoresController < Admin::Gamification::BaseController

  before_action :load_additional_score, only: [:edit, :update, :destroy]
  before_action :load_action, only: [:new, :create, :edit, :update]
  before_action :load_process, only: [:new, :create, :edit, :update]

  load_and_authorize_resource :action, class: "Gamification::Action"

  def new
    @additional_score = Gamification::Action::AdditionalScore.new
  end

  def create
    @additional_score = ::Gamification::Action::AdditionalScore.new(additional_score_params)
    @additional_score.gamification_action = @action
    @additional_score.process = @process

    if @additional_score.save
      redirect_to admin_gamification_action_path(@action), notice: t("admin.gamification.actions.additional_score.flash.created")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @additional_score.update(additional_score_params)
      redirect_to admin_gamification_action_path(@additional_score.gamification_action), notice: t("admin.gamification.actions.additional_score.flash.updated")
    else
      render :edit
    end
  end

  def destroy
    @action = @additional_score.gamification_action
    if @additional_score.destroy
      notice = t("admin.gamification.actions.additional_score.destroy.success_notice")
    else
      notice = t("flash.actions.destroy.error")
    end
    redirect_to admin_gamification_action_path(@action), notice: notice
  end

  private

    def load_action
      if @additional_score&.gamification_action.present? 
        @action = @additional_score.gamification_action
      else
        @action = ::Gamification::Action.find(params[:id] || params[:action_id])
      end
    end

    def load_process
      if @additional_score&.process.present? 
        @process = @additional_score.process
      elsif @action.process_type.present? && 
        @action.operation.present? && 
        ["create"].exclude?(@action.operation) 

        process_id = params[:process_id] || params[:gamification_action_additional_score][:process_id]
        case @action.process_type
          when "debate"
            @process = Debate.find(process_id)
          when "proposal"
            @process = Proposal.find(process_id)
          when "poll"
            @process = Poll.find(process_id)
          when "process"
            @process = ::Legislation::Process.find(process_id)
          when "forum"
            @process = Forum.find(process_id)
        end
      end
    end

    def additional_score_params
      attributes = [:action_id, :process_id, :additional_score]
      params.require(:gamification_action_additional_score).permit(*attributes)
    end

    def load_additional_score
      @additional_score = ::Gamification::Action::AdditionalScore.find(params[:id])
    end

    def resource
      load_additional_score unless @additional_score
      @additional_score
    end

end
