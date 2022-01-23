module TerminalsHelper

  def satisfaction_survey_select_options(selected_poll_id)
    select_options = Poll.only_terminals.order(starts_at: :desc).map { |p| [p.name, p.id] }
    options_for_select(select_options, selected: selected_poll_id)
  end

end
