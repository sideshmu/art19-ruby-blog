# frozen_string_literal: true

class Comment < ApplicationRecord
  include Visible
  include Approval

  belongs_to :article

  validates :commenter, presence: true
  validates :body, presence: true
end
