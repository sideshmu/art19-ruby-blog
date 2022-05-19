# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:article) { create(:article) }
  let(:comment) { build(:comment) }

  context "verify comment creation" do
    it "comment is valid with when assigned to an article" do
      article.comments << comment
      expect(comment).to be_valid
    end

    it "comment is invalid with when not assigned to an article" do
      expect(comment).to be_invalid
    end
  end

  context "verify comment deletion" do
    it "comment is deleted when article is deleted" do
      # Add comment to article
      article.comments << comment

      expect { article.destroy }.to change { Comment.count }.by(-1)
      expect { comment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
