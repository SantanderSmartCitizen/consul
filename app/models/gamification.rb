class Gamification < ApplicationRecord
  has_many :actions, inverse_of: :gamification, dependent: :destroy
  has_many :rewards, inverse_of: :gamification, dependent: :destroy
  has_many :user_rankings, inverse_of: :gamification, dependent: :destroy
  accepts_nested_attributes_for :actions, :rewards

  include Measurable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable


  validates_translation :title, presence: true, length: { in: 4..Gamification.title_max_length }
  # validates_translation :description, presence: true, length: { in: 10..Gamification.description_max_length }
  validates :key, presence: true, uniqueness: true

end
