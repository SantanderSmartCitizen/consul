class Milestone < ApplicationRecord
  include Imageable
  include Documentable
  include EmbedVideosHelper

  translates :title, :description, touch: true
  include Globalizable
  translation_class_delegate :status_id

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :milestoneable, polymorphic: true
  belongs_to :status
  belongs_to :author, class_name: "User", inverse_of: :milestones

  has_many :comments, as: :commentable, inverse_of: :commentable

  validates :milestoneable, presence: true
  validates :publication_date, presence: true
  validates_translation :description, presence: true, unless: -> { status_id.present? }

  validate :valid_video_url?

  scope :order_by_publication_date, -> { order(publication_date: :asc, created_at: :asc) }
  scope :published,                 -> { where("publication_date <= ?", Date.current.end_of_day) }
  scope :with_status,               -> { where("status_id IS NOT NULL") }

  def self.title_max_length
    80
  end

  def likes
    cached_votes_up
  end

  def dislikes
    cached_votes_down
  end

  def total_votes
    cached_votes_total
  end

  def votes_score
    cached_votes_total
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      Milestone.increment_counter(:cached_anonymous_votes_total, id) if user.unverified? && !user.voted_for?(self)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def votable_by?(user)
    return false unless user

    total_votes <= 100 ||
      !user.unverified? ||
      Setting["max_ratio_anon_votes_on_milestones"].to_i == 100 ||
      anonymous_votes_ratio < Setting["max_ratio_anon_votes_on_milestones"].to_i ||
      user.voted_for?(self)
  end

end
