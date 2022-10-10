class ManagementArea < ApplicationRecord
  has_many :managers

  validates :name, presence: true, uniqueness: true
end
