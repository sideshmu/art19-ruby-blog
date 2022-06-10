# frozen_string_literal: true

class Tag < ApplicationRecord
  scope :matching, ->(query) { where('title LIKE ?', "%#{query}%") }
  scope :by_article, ->(article_id) { joins(:taggings).merge(Tagging.where(article_id: article_id.to_s)) }

  has_many :taggings
  has_many :articles, through: :taggings

  validates :title, presence: true

  before_destroy :allow_destroy

  private

  def allow_destroy
    unless taggings_count.zero?
      errors.add(:base, 'cannot delete when currently used by Articles')
      throw(:abort)
    end
  end
end
