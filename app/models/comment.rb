# frozen_string_literal: true

class Comment < ApplicationRecord
  include Visible
  include Approval

  belongs_to :article

  validates :commenter, presence: true
  validates :body, presence: true

  before_update :change_approval_to_submitted, if: :will_save_change_to_body?
  after_save :queue_processing_job

  private

  def change_approval_to_submitted
    self.approval = APPROVAL_STATUS_SUBMITTED
  end

  def queue_processing_job
    ApprovalJob.perform_async(id) if approval == APPROVAL_STATUS_SUBMITTED
  end
end
