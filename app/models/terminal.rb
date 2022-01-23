class Terminal < ApplicationRecord
 
 belongs_to :poll

 validates :code, presence: true, uniqueness: true
 validates :serial_number, presence: true, uniqueness: true
 validates :name, presence: true, uniqueness: true

 has_many :terminal_statuses

 def status
    terminal_statuses.order(:created_at).last
 end

end
