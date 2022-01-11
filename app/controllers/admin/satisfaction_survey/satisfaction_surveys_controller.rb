class Admin::SatisfactionSurvey::SatisfactionSurveysController < Admin::SatisfactionSurvey::BaseController
  include Translatable

  load_and_authorize_resource :poll, class: "Poll"

  before_action :load_poll, only: [:show, :edit, :update, :destroy]

  def index
    @polls = Poll.not_budget.created_by_admin.only_terminals.order(starts_at: :desc)
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = Poll.new(poll_params.merge(author: current_user, only_terminals: true))
    if @poll.save
      redirect_to admin_satisfaction_survey_path(@poll), notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @poll.update(poll_params)
      redirect_to admin_satisfaction_survey_path(@poll), notice: t("flash.actions.update.poll")
    else
      render :edit
    end
  end

  def add_question
    question = ::Poll::Question.find(params[:question_id])

    if question.present?
      @poll.questions << question
      notice = t("admin.polls.flash.question_added")
    else
      notice = t("admin.polls.flash.error_on_question_added")
    end
    redirect_to admin_satisfaction_survey_path(@poll), notice: notice
  end

  def booth_assignments
    @polls = Poll.current.created_by_admin
  end

  def destroy
    # if ::Poll::Voter.where(poll: @poll).any?
      # redirect_to admin_satisfaction_survey_path(@poll), alert: t("admin.polls.destroy.unable_notice")
    # else
      @poll.destroy!
      redirect_to admin_satisfaction_surveys_path, notice: t("admin.polls.destroy.success_notice")
    # end
  end

  private

    def poll_params
      attributes = [:name]
      params.require(:poll).permit(*attributes, translation_params(Poll))
    end

    def load_poll
      @poll ||= Poll.find(params[:id])
    end

    def resource
      load_poll unless @poll
      @poll
    end
end
