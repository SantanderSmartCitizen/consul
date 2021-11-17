class WelcomeController < ApplicationController
  include RemotelyTranslatable

  skip_authorization_check
  before_action :set_user_recommendations, only: :index, if: :current_user
  before_action :authenticate_user!, only: :welcome

  layout "devise", only: [:welcome, :verification]

  def index
    @header = Widget::Card.header.first
    @feeds = Widget::Feed.active
    @cards = Widget::Card.body
    @banners = Banner.in_section("homepage").with_active
    @header_slides = HeaderSlide.homepage
    @remote_translations = detect_remote_translations(@feeds,
                                                      @recommended_debates,
                                                      @recommended_proposals)
    @current_budget = current_budget
    if @current_budget.present?
      @stats = Budget::Stats.new(@current_budget)
    end
    start_date = params.fetch(:start_date, Date.today).to_date
    date_range = start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week
    @events = Event.where(start_time: date_range).or(Event.where(end_time: date_range))
    @complaint = Complaint.new
  end

  def welcome
    if current_user.level_three_verified?
      redirect_to page_path("welcome_level_three_verified")
    elsif current_user.level_two_or_three_verified?
      redirect_to page_path("welcome_level_two_verified")
    else
      redirect_to page_path("welcome_not_verified")
    end
  end

  def verification
    redirect_to verification_path if signed_in?
  end

  def send_complaint
    redirect_to root_path
  end

  private

    def set_user_recommendations
      @recommended_debates = Debate.recommendations(current_user).sort_by_recommendations.limit(3)
      @recommended_proposals = Proposal.recommendations(current_user).sort_by_recommendations.limit(3)
    end
end
