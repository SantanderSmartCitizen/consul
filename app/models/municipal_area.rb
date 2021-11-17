class MunicipalArea < ApplicationRecord
	translates :title, touch: true
	include Globalizable

	has_many :municipal_area_assignments, dependent: :destroy
	has_many :users, through: :municipal_area_assignments
end
