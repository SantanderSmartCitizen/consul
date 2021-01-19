class Gamification::UserRanking < ApplicationRecord
  belongs_to :user
  belongs_to :gamification

  default_scope { order(score: :desc) }

  def ranking_position
    ::Gamification::UserRanking.where("score > ? AND gamification_id = ?", self.score, self.gamification_id).count + 1
  end

end
