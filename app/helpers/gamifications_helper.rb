module GamificationsHelper

  def gamification_select_options(include_all = nil)
    options = @gamifications.map do |gamification|
      [gamification.key, current_path_with_query_params(gamification_id: gamification.id)]
    end
    options << all_gamifications if include_all
    options_for_select(options, request.fullpath)
  end

  def all_gamifications
    [I18n.t("gamifications.all"), admin_gamifications_path]
  end

  def gamification_action_process_types
    Gamification::Action::PROCESS_TYPES.map { |type| [t("admin.gamification.actions.process_types.#{type}"), type] }
  end

end
