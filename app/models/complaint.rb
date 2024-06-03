class Complaint < ApplicationRecord

  validates :subject, presence: true
  validates :body, presence: true
  validates :department, presence: true

end
