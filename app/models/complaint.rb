class Complaint < ApplicationRecord

  validates :user, presence: true
  validates :subject, presence: true
  validates :body, presence: true

end
