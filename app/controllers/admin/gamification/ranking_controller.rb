class Admin::Gamification::RankingController < Admin::Gamification::BaseController
  before_action :load_gamification

  def index
=begin    
    @booth_assignments = @poll.booth_assignments.
                              includes(:booth, :recounts, :voters).
                              order("poll_booths.name").
                              page(params[:page]).per(50)

=end
  end

  private

    def load_gamification
      @gamification = ::Gamification.find(params[:gamification_id])
    end
end
