class HeaderSlide < ApplicationRecord
  include Imageable

  translates :title,       touch: true
  include Globalizable

  validates_translation :title, presence: true, length: { minimum: 2 }
  validates_presence_of :image

  PAGES = %w[homepage budgets polls debates proposals legislation_processes forums help].freeze

  scope :in_page, ->(page_name) { where(page: page_name) }

  scope :homepage,  			-> { in_page("homepage") }
  scope :budgets,   			-> { in_page("budgets") }
  scope :polls,   				-> { in_page("polls") }
  scope :debates,   			-> { in_page("debates") }
  scope :proposals,   			-> { in_page("proposals") }
  scope :legislation_processes, -> { in_page("legislation_processes") }
  scope :forums,   				-> { in_page("forums") }
  scope :help,   				-> { in_page("help") }

end
