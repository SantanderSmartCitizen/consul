class Event < ApplicationRecord
  include Imageable

  translates :title,       touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :title, presence: true, length: { minimum: 2 }
  validates_translation :description, presence: true
  # validates_presence_of :image
  validate :date_range

  scope :previous,   -> { where("end_time < ?", Time.now.at_beginning_of_day) }
  scope :next,   -> { where("start_time >= ?", Time.now.at_beginning_of_day) }

  def date_range
    unless start_time.present? && end_time.present? && start_time <= end_time
      errors.add(:start_time, I18n.t("errors.messages.invalid_date_range"))
    end
  end
end
