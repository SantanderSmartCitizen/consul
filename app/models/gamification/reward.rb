class Gamification::Reward < ApplicationRecord

  include Measurable
  include Documentable
  include Linkable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  validates :gamification_id, presence: true
  validates_translation :title, presence: true, length: { in: 4..Gamification::Reward.title_max_length }
  validates_translation :description, presence: true, length: { in: 10..Gamification::Reward.description_max_length }
  validates :minimum_score, presence: true, length: { in: 1..10 }

  belongs_to :gamification
  
end
