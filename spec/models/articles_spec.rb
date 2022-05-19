# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:valid_article_attributes) do
    {
      title: 'Test title',
      body: 'Test body which is long',
      status: 'public'
    }
  end

  let(:invalid_article_attributes) do
    {
      title: 'Test title',
      body: 'shortbody',
      status: 'invalid_status'
    }
  end

  context 'verify article creation' do
    let(:article) { Article.create(valid_article_attributes) }

    it 'article is valid with valid attributes' do
      expect(article).to be_valid
    end

    let(:invalid_article) { Article.create(invalid_article_attributes) }

    it 'article is invalid with invalid attributes' do
      expect(invalid_article).not_to be_valid
    end
  end

  context 'verify uniqueness of article title' do
    let(:article) { build(:article, title: 'identical') }

    before do
      create(:article, title: 'identical')
    end

    it 'article with same title is not created' do
      expect(article).to be_invalid
    end
  end
end
