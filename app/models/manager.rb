class Manager < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :management_area
  
  delegate :name, :email, :name_and_email, to: :user

  validates :user_id, presence: true, uniqueness: true
end
