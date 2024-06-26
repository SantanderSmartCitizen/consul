module PollsHelper
  def poll_select_options(include_all = nil)
    options = @polls.map do |poll|
      [poll.name, current_path_with_query_params(poll_id: poll.id)]
    end
    options << all_polls if include_all
    options_for_select(options, request.fullpath)
  end

  def all_polls
    [I18n.t("polls.all"), admin_questions_path]
  end

  def all_answer_types
    [I18n.t("admin.questions.index.all_answer_types"), admin_questions_path]
  end

  def poll_dates(poll)
    if poll.starts_at.blank? || poll.ends_at.blank?
      I18n.t("polls.no_dates")
    else
      I18n.t("polls.dates", open_at: l(poll.starts_at.to_date), closed_at: l(poll.ends_at.to_date))
    end
  end

  def booth_name_with_location(booth)
    location = booth.location.blank? ? "" : " (#{booth.location})"
    booth.name + location
  end

  def poll_voter_token(poll, user)
    Poll::Voter.find_by(poll: poll, user: user, origin: "web")&.token || ""
  end

  def voted_before_sign_in(question)
    question.answers.where(author: current_user).any? { |vote| current_user.current_sign_in_at > vote.updated_at }
  end

  def link_to_poll(text, poll)
    if can?(:results, poll)
      link_to text, results_poll_path(id: poll.slug || poll.id)
    elsif can?(:stats, poll)
      link_to text, stats_poll_path(id: poll.slug || poll.id)
    else
      link_to text, poll_path(id: poll.slug || poll.id)
    end
  end

  def results_menu?
    controller_name == "polls" && action_name == "results"
  end

  def stats_menu?
    controller_name == "polls" && action_name == "stats"
  end

  def info_menu?
    controller_name == "polls" && action_name == "show"
  end

  def show_polls_description?
    @active_poll.present? && @current_filter == "current"
  end

  def poll_question_answer_types
    Poll::Question::ANSWER_TYPES.map { |type| [t("admin.questions.question_types.#{type}"), type] }
  end

  def satisfaction_survey_question_answer_types
    Poll::Question::SATISFACTION_ANSWER_TYPES.map { |type| [t("admin.questions.question_types.#{type}"), type] }
  end

  def poll_question_answer_types_select_options(include_all = nil)
    answer_type_options = Poll::Question::ANSWER_TYPES.map do |type| 
      [t("admin.questions.question_types.#{type}"), current_path_with_query_params(answer_type: type)] 
    end
    answer_type_options << all_answer_types if include_all
    options_for_select(answer_type_options, request.fullpath)
  end

end
