class Gamification::Reward < ApplicationRecord

  include Measurable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable


  validates_translation :title, presence: true, length: { in: 4..Gamification::Reward.title_max_length }
  validates_translation :description, presence: true, length: { in: 10..Gamification::Reward.description_max_length }
  validates_translation :reward, presence: true, length: { in: 4..Gamification::Reward.description_max_length }
  validates :key, presence: true, uniqueness: true

  belongs_to :gamification
  
end
