# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe 'Comments requests', type: :request do
  let(:parsed_response) { JSON.parse(response.body) }
  let(:article)         { create(:article) }
  let(:comment)         { build(:comment) }

  let(:invalid_comment_attributes) do
    {
      commenter: 'Random commenter',
      status: 'invalid status'
    }
  end

  let(:approved_comment_attributes) do
    {
      commenter: 'Good Guy Gary',
      body: 'Only writes good comments!',
      status: 'public'
    }
  end

  let(:flagged_comment_attributes) do
    {
      commenter: 'Bad Guy Ben',
      body: 'Only writes bad comments! zoinks!',
      status: 'public'
    }
  end

  describe 'GET /index' do
    before do
      commenters = %w[Sam Pam Ham]
      commenters.each do |commenter|
        article.comments << build(:comment, commenter: commenter)
      end
      get article_comments_path(article.id), params: { approval: 'submitted' }
    end

    it 'returns http success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'contains all submitted comments for the article in json response' do
      expect(parsed_response.map { |comment| comment['commenter'] }).to match_array(%w[Sam Pam Ham])
    end
  end

  describe 'POST /create' do
    context 'with valid comment attributes verify comment creation' do
      before { post article_comments_path(article.id), params: { comment: approved_comment_attributes } }

      it { expect(response).to have_http_status(:created) }
      it { expect(parsed_response['commenter']).to eq(approved_comment_attributes[:commenter]) }
      it { expect(parsed_response['body']).to eq(approved_comment_attributes[:body]) }
      it { expect(parsed_response['status']).to eq(approved_comment_attributes[:status]) }
      it { expect(parsed_response['approval']).to eq('submitted') }
    end

    context 'with invalid comment attributes verify comment creation' do
      before { post article_comments_path(article.id), params: { comment: invalid_comment_attributes } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(parsed_response['body']).to include(/can't be blank/) }
      it { expect(parsed_response['status']).to include(/is not included in the list/) }
    end
  end

  describe 'PUT /update' do
    context 'with approved comment verify comment updation' do
      before do
        # Add a comment, approval is now 'approved'
        article.comments << comment
        ApprovalJob.new.perform(comment.id)
        comment.reload

        # Update the comment
        put article_comment_path(article.id, comment.id), params: { comment: approved_comment_attributes }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates commenter' do
        expect(parsed_response['commenter']).to eq(approved_comment_attributes[:commenter])
      end

      it "updates comment with status 'submitted'" do
        expect(parsed_response['approval']).to eq('submitted')
      end
    end
  end

  describe 'DELETE /destroy' do
    before { article.comments << comment }

    context 'when deleting a comment' do
      before { delete article_comment_path(article.id, comment.id) }

      it 'returns http no_content and deletes comment' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when deleting article with comment' do
      before { delete article_path(article.id) }

      it 'deletes article' do
        expect { article.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'deletes comment' do
        expect { comment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
