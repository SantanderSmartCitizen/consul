class Gamification::UserAction < ApplicationRecord
  belongs_to :user
  belongs_to :gamification_action, class_name: "Gamification::Action"
  belongs_to :process, polymorphic: true

end
