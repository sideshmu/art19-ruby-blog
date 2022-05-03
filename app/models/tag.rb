class Tag < ApplicationRecord
  has_and_belongs_to_many :articles, :dependent => :restrict_with_error

  validates :title, presence: true
  validates :counter, presence: true, numericality: { only_integer: true }
    
  before_destroy :allow_destroy
  private 
    def allow_destroy
      unless self.articles.empty?
        self.errors.add('Cannot_delete','In use by Articles')
        throw(:abort)
      end
    end
end
