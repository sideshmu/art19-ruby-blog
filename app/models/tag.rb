# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings
  has_many :articles, through: :taggings

  validates :title, presence: true
    
  before_destroy :allow_destroy

  private 
    def allow_destroy
      unless self.taggings_count == 0
        errors.add(:base, 'cannot delete when currently used by Articles')
        throw(:abort)
      end
    end
end
