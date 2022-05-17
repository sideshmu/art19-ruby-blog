# frozen_string_literal: true

class Article < ApplicationRecord
    include Visible
  
    has_many :comments, dependent: :destroy
    has_many :taggings
    has_many :tags, through: :taggings
  
    validates :title, presence: true, uniqueness: true
    validates :body, presence: true, length: { minimum: 10 }
  end
  