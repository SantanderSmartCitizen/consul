module GamificationsHelper

  # def gamification_select_options(include_all = nil)
  #   options = @gamifications.map do |gamification|
  #     [gamification.key, current_path_with_query_params(gamification_id: gamification.id)]
  #   end
  #   options << all_gamifications if include_all
  #   options_for_select(options, request.fullpath)
  # end

  # def all_gamifications
  #   [I18n.t("gamifications.all"), admin_gamifications_path]
  # end

  def gamification_select_options
    select_options = Gamification.all.map { |p| [p.key, p.id] }
    options_for_select(select_options)
  end

  def get_process_type_select_options
    Gamification::Action::PROCESS_TYPES.keys.map { |type| [t("admin.gamification.actions.process_types.#{type}"), type] }
  end

  def get_operation_select_options(process_type)
    if process_type.present?
      Gamification::Action::PROCESS_TYPES[process_type]&.map { |operation| [t("admin.gamification.actions.operations.#{operation}"), operation] }
    else
      Array(nil)
    end
  end

end
