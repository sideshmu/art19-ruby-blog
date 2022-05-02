class ApprovalJob
  include Sidekiq::Job

  TRIGGER_WORDS = %w[zoinks yoinks doinks oinks boinks]

  def perform(comment_id)
    comment = Comment.find_by_id(comment_id)
    # Search for trigger words
    if /\b#{Regexp.union(TRIGGER_WORDS).source}\b/i === comment.body
      comment.update(approval: "flagged")
    else
      comment.update(approval: "approved") 
    end
  end
end
