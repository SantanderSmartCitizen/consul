class Gamification::Action < ApplicationRecord

  include Measurable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable


  validates :gamification_id, presence: true
  validates :key, presence: true, uniqueness: true
  validates_translation :title, presence: true, length: { in: 4..Gamification::Action.title_max_length }
  validates_translation :description, presence: true, length: { in: 10..Gamification::Action.description_max_length }
  validates :score, presence: true, length: { in: 1..6 }

  belongs_to :gamification
  
end
