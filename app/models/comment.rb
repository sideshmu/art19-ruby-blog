# frozen_string_literal: true

class Comment < ApplicationRecord
  APPROVAL_STATUS_APPROVED  = 'approved'
  APPROVAL_STATUS_FLAGGED   = 'flagged'
  APPROVAL_STATUS_SUBMITTED = 'submitted'
  
  include Approval, Visible

  belongs_to :article

  validates :commenter, presence: true
  validates :body, presence: true
end
