# frozen_string_literal: true

class Tagging < ApplicationRecord
  # belongs_to :tag, counter_cache: taggings_count
  belongs_to :tag, counter_cache: true
  belongs_to :article

  validates :article_id, presence: true
  validates :tag_id, presence: true

  before_save :abort_unless_tag_exists
  before_save :abort_unless_article_exists

  private

  def abort_unless_tag_exists
    unless Tag.exists?(id: tag_id)
      errors.add(:base, 'tag does not exist')
      throw(:abort)
    end
  end

  def abort_unless_article_exists
    unless Article.exists?(id: article_id)
      errors.add(:base, 'article does not exist')
      throw(:abort)
    end
  end
end
