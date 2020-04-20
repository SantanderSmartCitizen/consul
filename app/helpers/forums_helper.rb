module ForumsHelper
  def has_featured?
    Forum.all.featured.count > 0
  end

  def empty_recommended_forums_message_text(user)
    if user.interests.any?
      t("forums.index.recommendations.without_results")
    else
      t("forums.index.recommendations.without_interests")
    end
  end

  def forums_minimal_view_path
    forums_path(view: forums_secondary_view)
  end

  def forums_default_view?
    @view == "default"
  end

  def forums_current_view
    @view
  end

  def forums_secondary_view
    forums_current_view == "default" ? "minimal" : "default"
  end
end
