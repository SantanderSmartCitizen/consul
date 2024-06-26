module FeedsHelper
  def feed_debates?(feed)
    feed.kind == "debates"
  end

  def feed_proposals?(feed)
    feed.kind == "proposals"
  end

  def feed_city_hall_proposals?(feed)
    feed.kind == "city_hall_proposals"
  end

  def feed_citizen_proposals?(feed)
    feed.kind == "citizen_proposals"
  end

  def feed_processes?(feed)
    feed.kind == "processes"
  end

  def feed_debates_enabled?
    Setting["homepage.widgets.feeds.debates"].present?
  end

  def feed_proposals_enabled?
    Setting["homepage.widgets.feeds.proposals"].present?
  end

  def feed_city_hall_proposals_enabled?
    Setting["homepage.widgets.feeds.city_hall_proposals"].present?
  end

  def feed_citizen_proposals_enabled?
    Setting["homepage.widgets.feeds.citizen_proposals"].present?
  end

  def feed_processes_enabled?
    Setting["homepage.widgets.feeds.processes"].present?
  end

  def feed_debates_and_proposals_enabled?
    feed_debates_enabled? && feed_proposals_enabled?
  end
end
