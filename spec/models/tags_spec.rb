# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  
  let(:article) { create(:article) }
  let(:tag) { create(:tag) }

  context "verify tag creation" do

    it "tag is valid with valid attributes" do
      expect(tag).to be_valid 
    end
  end

  context "verify tag deletion" do

    it "tag is destroyed when not used in an article" do
      tag.destroy

      expect(tag).to be_destroyed
      expect(tag.errors[:base]).to be_empty
    end

    it "tag is not destroyed when used in an article" do
      # Add tag to article
      article.tags << tag
      tag.destroy

      expect(tag).not_to be_destroyed
      expect(tag.errors[:base]).to eq ['cannot delete when currently used by Articles']
      raise_error(ActiveRecord::RecordNotFound)
    end
  end
end