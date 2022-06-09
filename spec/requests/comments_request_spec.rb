# frozen_string_literal: true

require 'rails_helper'
require 'json'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe 'Comments requests', type: :request do
  let(:parsed_response)     { JSON.parse(response.body) }
  let(:article)             { create(:article) }
  let(:comment)             { build(:comment) }

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
    end

    it "returns http success and contains all 'submitted comments' for the article in json response" do
      get article_comments_path(article.id), params: { approval: 'submitted' }
      expect(response).to have_http_status(:ok)
      expect(parsed_response.map { |comment| comment['commenter'] }).to match_array(%w[Sam Pam Ham])
    end
  end

  describe 'POST /create' do
    context 'verify comment creation' do
      it "returns http created and creates a new comment with status 'submitted'" do
        post article_comments_path(article.id), params: { comment: approved_comment_attributes }

        expect(response).to have_http_status(:created)

        expect(parsed_response['commenter']).to eq(approved_comment_attributes[:commenter])
        expect(parsed_response['body']).to eq(approved_comment_attributes[:body])
        expect(parsed_response['status']).to eq(approved_comment_attributes[:status])
        expect(parsed_response['approval']).to eq('submitted')
      end

      it 'returns http unprocessable_entity and when invalid comment attributes are passed' do
        post article_comments_path(article.id), params: { comment: invalid_comment_attributes }

        expect(response).to have_http_status(:unprocessable_entity)

        expect(parsed_response['body']).to include(/can't be blank/)
        expect(parsed_response['status']).to include(/is not included in the list/)
      end
    end
  end

  describe 'PUT /update' do
    context 'verify comment updation' do
      it "returns http success and returns updated comment with status 'submitted'" do
        # Add a comment, check approval is 'approved'
        article.comments << comment
        ApprovalJob.new.perform(comment.id)
        comment.reload
        expect(comment.commenter).to eq('Bob')
        expect(comment.approval).to eq('approved')

        # Update the comment, check approval is 'submitted'
        put article_comment_path(article.id, comment.id), params: { comment: approved_comment_attributes }

        expect(response).to have_http_status(:ok)
        expect(parsed_response['commenter']).to eq(approved_comment_attributes[:commenter])
        expect(parsed_response['approval']).to eq('submitted')
      end
    end
  end

  describe 'DELETE /destroy' do
    before do
      article.comments << comment
    end

    context 'verify comment deletion' do
      it 'returns http no_content and deletes comment' do
        delete article_comment_path(article.id, comment.id)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'verify article deletion with comment' do
      it 'returns http no_content and deletes article as well as comment' do
        delete article_path(article.id)

        expect { article.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { comment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
