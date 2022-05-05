require "rails_helper"
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe CommentsController, type: :controller do
  let(:approved_comment_attributes) do
    {
      commenter: "Good Guy Gary", 
      body: "Only writes good comments!", 
      status: "public",
      approval: "submitted"
    }
  end

  let(:flagged_comment_attributes) do
    {
      commenter: "Bad Guy Ben", 
      body: "Only writes bad comments! zoinks!", 
      status: "public",
      approval: "submitted"
    }
  end

  let(:valid_article_attributes) do
    {
      title: "Test title", 
      body: "Test body which is long", 
      status: "public"
    }
  end

  context "verify comment creation" do
    let!(:article) { Article.create(valid_article_attributes) }
    let!(:comment) { article.comments.create(approved_comment_attributes)}

    it "comment is valid with valid attributes" do
      expect(comment).to be_valid 
    end
  end

  context "verify comment approval process" do
    let!(:article) { Article.create(valid_article_attributes) }
    let!(:good_comment) { article.comments.create(approved_comment_attributes)}
    let!(:bad_comment) { article.comments.create(flagged_comment_attributes)}
    
    it "comment is approved when no trigger words found" do
      ApprovalJob.new.perform(good_comment.id)
      updated_comment = article.comments.find_by_id(good_comment.id)
      expect(updated_comment.approval).to match('approved')
    end

    it "comment is flagged when trigger words found" do
      ApprovalJob.new.perform(bad_comment.id)
      updated_comment = article.comments.find_by_id(bad_comment.id)
      expect(updated_comment.approval).to match('flagged')
    end
  end
end