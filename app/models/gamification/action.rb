class Gamification::Action < ApplicationRecord
  belongs_to :gamification
  has_many :gamification_additional_scores, inverse_of: :gamification_action, dependent: :destroy, class_name: "Gamification::AdditionalScore"

  PROCESS_TYPES = %w[debate proposal poll budget_investment process forum].freeze

  include Measurable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable


  # validates :gamification_id, presence: true
  # validates_associated :gamification
  validates :key, presence: true
  validates_uniqueness_of :key, scope: [:gamification_id]
  validates_translation :title, presence: true, length: { in: 3..Gamification::Action.title_max_length }
  #validates_translation :description, presence: true, length: { in: 10..Gamification::Action.description_max_length }
  validates :score, presence: true, length: { in: 1..6 }

  validates :process_type, presence: true, unless: "operation.blank?"
  validates :operation, presence: true, unless: "process_type.blank?"
  validates_uniqueness_of :operation, scope: [:gamification_id, :process_type], unless: "process_type.blank?"
  
end
