class Gamification::UserRanking < ApplicationRecord
  belongs_to :user
  belongs_to :gamification

  default_scope { order(score: :desc) }

end
