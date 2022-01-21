class Admin::SatisfactionSurvey::QuestionsController < Admin::SatisfactionSurvey::BaseController
  include CommentableActions
  include Translatable

  load_and_authorize_resource :poll, class: "Poll"
  load_and_authorize_resource :question, class: "Poll::Question"

  def new
  end

  def create
    @question.author = current_user

    if @question.save
      redirect_to admin_satisfaction_survey_question_path(@question)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to admin_satisfaction_survey_question_path(@question), notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    if @question.destroy
      notice = t("admin.satisfaction_surveys.questions.destroy.success_notice")
    else
      notice = t("flash.actions.destroy.error")
    end
    redirect_to request.referer, notice: notice
  end

  private

    def question_params
      attributes = [:poll_id, :question, :answer_type]
      params.require(:poll_question).permit(*attributes, translation_params(Poll::Question))
    end

    # def resource
    #   @poll_question ||= Poll::Question.find(params[:id])
    # end
end
