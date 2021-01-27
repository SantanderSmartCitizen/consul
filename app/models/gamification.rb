class Gamification < ApplicationRecord
  has_many :actions, inverse_of: :gamification, dependent: :restrict_with_error
  has_many :rewards, inverse_of: :gamification, dependent: :restrict_with_error
  has_many :user_rankings, inverse_of: :gamification, dependent: :restrict_with_error, class_name: "Gamification::UserRanking", foreign_key: "gamification_id"

  accepts_nested_attributes_for :actions, :rewards

  include Measurable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :title, presence: true, length: { in: 4..Gamification.title_max_length }
  # validates_translation :description, presence: true, length: { in: 10..Gamification.description_max_length }
  validates :key, presence: true, uniqueness: true

  scope :no_locked, -> { where(locked: false) }

  def active_rewards
    rewards.active
  end

  def user_score(user)    
    user_ranking = user_rankings.where(user_id: user.id).order(created_at: :desc).first
    return 0 if user_ranking.nil? || user_ranking.score.nil?
    user_ranking.score
  end

end
