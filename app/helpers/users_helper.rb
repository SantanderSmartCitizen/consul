module UsersHelper
  def humanize_document_type(document_type)
    case document_type
    when "1"
      t "verification.residence.new.document_type.spanish_id"
    when "2"
      t "verification.residence.new.document_type.passport"
    when "3"
      t "verification.residence.new.document_type.residence_card"
    end
  end

  def comment_commentable_title(comment)
    commentable = comment.commentable
    if commentable.nil?
      deleted_commentable_text(comment)
    elsif commentable.hidden?
      content_tag(:del, commentable.title) + " " +
      content_tag(:span, "(" + deleted_commentable_text(comment) + ")", class: "small")
    else
      link_to(commentable.title, comment)
    end
  end

  def deleted_commentable_text(comment)
    case comment.commentable_type
    when "Proposal"
      t("users.show.deleted_proposal")
    when "Debate"
      t("users.show.deleted_debate")
    when "Forum"
      t("users.show.deleted_forum")
    when "Budget::Investment"
      t("users.show.deleted_budget_investment")
    else
      t("users.show.deleted")
    end
  end

  def current_administrator?
    current_user&.administrator?
  end

  def current_moderator?
    current_user&.moderator?
  end

  def current_valuator?
    current_user&.valuator?
  end

  def current_manager?
    current_user&.manager?
  end

  def current_poll_officer?
    current_user&.poll_officer?
  end

  def show_admin_menu?(user = nil)
    unless namespace == "officing"
      current_administrator? || current_moderator? || current_valuator? || current_manager? ||
        (user&.administrator?) || current_poll_officer?
    end
  end

  def interests_title_text(user)
    if current_user == user
      t("account.show.public_interests_my_title_list")
    else
      t("account.show.public_interests_user_title_list")
    end
  end


  def gamification_reward_card_class(gamification_reward, user)
    return "alert" unless gamification_reward.active_for?(user)
    return "success" if gamification_reward.executed_for?(user)

    "primary"
  end

  def gamification_reward_tooltip(gamification_reward, user)
    return t("users.show.rewards.reward_locked") unless gamification_reward.active_for?(user)
    return t("users.show.rewards.view_reward") if gamification_reward.executed_for?(user) || (!gamification_reward.request_to_administrators && gamification_reward.active_for?(@user))
    return t("users.show.rewards.reward_requested") if gamification_reward.requested_for?(user)

    t("users.show.rewards.request_reward")
  end

  def gamification_reward_availability_label(gamification_reward)
    t("users.show.rewards.required_score", 
      score: number_with_delimiter(gamification_reward.minimum_score, 
        delimiter: ".")) 
  end
end
