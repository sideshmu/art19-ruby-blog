# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:article)             { create(:article) }
  let(:good_comment)        { build(:comment, body: 'good comment') }
  let(:bad_comment)         { build(:comment, body: 'yoinks !') }

  context 'verify comment approval process' do
    before do
      article.comments << good_comment
      article.comments << bad_comment
    end

    it 'comment is approved when no trigger words found' do
      expect(good_comment.approval).to match('submitted')
      ApprovalJob.new.perform(good_comment.id)
      good_comment.reload
      expect(good_comment.approval).to match('approved')
    end

    it 'comment is flagged when trigger words found' do
      expect(bad_comment.approval).to match('submitted')
      ApprovalJob.new.perform(bad_comment.id)
      bad_comment.reload
      expect(bad_comment.approval).to match('flagged')
    end
  end
end
