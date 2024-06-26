class Widget::Feed < ApplicationRecord
  self.table_name = "widget_feeds"

  KINDS = %w[city_hall_proposals citizen_proposals processes].freeze

  def active?
    setting.value.present?
  end

  def setting
    Setting.find_by(key: "homepage.widgets.feeds.#{kind}")
  end

  def self.active
    KINDS.map do |kind|
      feed = find_or_create_by!(kind: kind)
      feed if feed.active?
    end.compact
  end

  def items
    send(kind)
  end

  def proposals
    Proposal.sort_by_hot_score.limit(limit)
  end

  def city_hall_proposals
    Proposal.city_hall.sort_by_hot_score.limit(limit)
  end

  def citizen_proposals
    Proposal.citizen.sort_by_hot_score.limit(limit)
  end

  def debates
    Debate.sort_by_hot_score.limit(limit)
  end

  def processes
    Legislation::Process.open.published.order('created_at DESC').limit(limit)
  end
end
