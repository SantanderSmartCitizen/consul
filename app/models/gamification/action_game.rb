class Gamification::ActionGame < ApplicationRecord

  belongs_to :gamification
  belongs_to :action, class_name: "Gamification::Action", foreign_key: "gamification_action_id"

  validates :gamification, presence: true
  validates :action, presence: true

end
