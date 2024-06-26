module AdminHelper
  def side_menu
    if namespace == "moderation/budgets"
      render "/moderation/menu"
    else
      render "/#{namespace}/menu"
    end
  end

  def namespaced_root_path
    "/#{namespace}"
  end

  def namespaced_header_title
    if namespace == "moderation/budgets"
      t("moderation.header.title")
    else
      t("#{namespace}.header.title")
    end
  end

  def menu_moderated_content?
    moderated_sections.include?(controller_name) && controller.class.parent != Admin::Legislation
  end

  def moderated_sections
    ["hidden_proposals", "hidden_debates", "hidden_forums", "hidden_comments", "hidden_users", "activity",
     "hidden_budget_investments"]
  end

  def menu_budgets?
    controller_name.starts_with?("budget") && controller_name != "budget_geozones"
  end

  def menu_polls?
    !menu_satisfaction_surveys? &&
    (controller.class.parent == Admin::Poll::Questions::Answers ||
      %w[polls active_polls recounts results questions answers].include?(controller_name) &&
      action_name != "booth_assignments")
  end

  def menu_satisfaction_surveys?
    controllers_names = ["satisfaction_surveys"]
    controller_params = ["admin/satisfaction_survey/questions", "admin/satisfaction_survey/questions/answers"]
    controllers_names.include?(controller_name) || controller_params.include?(params[:controller])
  end

  def menu_gamifications?
    controllers_names = ["gamifications"]
    controller_params = ["admin/gamification/actions", "admin/gamification/actions/additional_scores", "admin/gamification/rewards", "admin/gamification/requested_rewards"]
    controllers_names.include?(controller_name) || controller_params.include?(params[:controller])
  end

  def menu_terminals?
    controllers_names = ["terminals"]
    controllers_names.include?(controller_name)
  end

  def menu_booths?
    %w[officers booths shifts booth_assignments officer_assignments].include?(controller_name) ||
      controller_name == "polls" && action_name == "booth_assignments"
  end

  def menu_admin_users?
    controllers_names = ["employees", "users", "organizations"]
    controllers_names.include?(controller_name)
  end

  def menu_profiles?
    controllers_names = ["administrators", "valuators", "managers", "moderators", "officials"]
    controllers_names.include?(controller_name)
  end

  def menu_settings?
    controllers_names = ["settings", "tags", "geozones", "budget_geozones", "images", "content_blocks",
      "local_census_records", "imports"]
    controllers_names.include?(controller_name) &&
      controller.class.parent != Admin::Poll::Questions::Answers
  end

  def menu_customization?
    ["pages", "banners", "header_slides", "information_texts", "documents", "events"].include?(controller_name) ||
    menu_homepage? || menu_pages?
  end

  def menu_homepage?
    ["homepage", "cards"].include?(controller_name) && params[:page_id].nil?
  end

  def menu_pages?
    ["pages", "cards"].include?(controller_name) && params[:page_id].present?
  end

  def menu_dashboard?
    ["administrator_tasks"].include?(controller_name) ||
     ["admin/dashboard/actions"].include?(params[:controller])
  end

  def submenu_local_census_records?
    controller_name == "local_census_records" ||
    (controller_name == "imports" && controller.class.parent == Admin::LocalCensusRecords)
  end

  def official_level_options
    options = [["", 0]]
    (1..5).each do |i|
      options << [[t("admin.officials.level_#{i}"), setting["official_level_#{i}_name"]].compact.join(": "), i]
    end
    options
  end

  def admin_select_options
    Administrator.with_user.map { |v| [v.description_or_name, v.id] }.sort_by { |a| a[0] }
  end

  def admin_submit_action(resource)
    resource.persisted? ? "edit" : "new"
  end

  def user_roles(user)
    roles = []
    roles << :admin if user.administrator?
    roles << :moderator if user.moderator?
    roles << :valuator if user.valuator?
    roles << :manager if user.manager?
    roles << :poll_officer if user.poll_officer?
    roles << :official if user.official?
    roles << :organization if user.organization?
    roles
  end

  def display_user_roles(user)
    user_roles(user).join(", ")
  end

  private

    def namespace
      controller.class.name.downcase.split("::").first
    end
end
