class BudgetGeozone < ApplicationRecord
  validates :name, presence: true
  validates :external_code, presence: true

  def self.names
    BudgetGeozone.pluck(:name)
  end
end