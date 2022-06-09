# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:article) { create(:article) }
  let(:tag) { create(:tag) }

  context 'verify tag creation' do
    it 'tag is valid with valid attributes' do
      expect(tag).to be_valid
    end
  end

  context 'verify tag deletion when not in use by an article' do
    before { tag.destroy }

    it 'tag is destroyed when not used in an article' do
      expect(tag).to be_destroyed
    end

    it 'tag destroy does not give any errors when tag not used in an article' do
      expect(tag.errors[:base]).to be_empty
    end
  end

  context 'verify tag deletion when used in an article' do
    # Add tag to article
    before do
      article.tags << tag
      tag.destroy
    end

    it 'tag is not destroyed when used in an article' do
      expect(tag).not_to be_destroyed
    end

    it 'tag destroy gives errors when tag is used in an article' do
      expect(tag.errors[:base]).to eq ['cannot delete when currently used by Articles']
    end
  end
end
