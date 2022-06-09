# frozen_string_literal: true

class ApprovalJob
  include Sidekiq::Job

  TRIGGER_WORDS = %w[zoinks yoinks doinks oinks boinks].freeze

  def perform(comment_id)
    comment = Comment.find_by_id(comment_id)
    # Search for trigger words
    if /\b#{Regexp.union(TRIGGER_WORDS).source}\b/i === comment.body
      comment.update(approval: Approval::APPROVAL_STATUS_FLAGGED)
    else
      comment.update(approval: Approval::APPROVAL_STATUS_APPROVED)
    end
  end
end
