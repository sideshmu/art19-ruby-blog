# frozen_string_literal: true

module Approval
  extend ActiveSupport::Concern

  APPROVAL_STATUSES = [
    Comment::APPROVAL_STATUS_APPROVED,
    Comment::APPROVAL_STATUS_FLAGGED,
    Comment::APPROVAL_STATUS_SUBMITTED,
  ]

  included do
    validates :approval, inclusion: { in: APPROVAL_STATUSES }
  end

  # class_methods do
  #   def public_count
  #     where(status: 'public').count
  #   end
  # end

  # def archived?
  #   status == 'archived'
  # end
end
