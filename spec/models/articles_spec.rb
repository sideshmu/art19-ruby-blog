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

  context 'when article is created' do
    let(:article)        { Article.create(valid_article_attributes) }
    let(:invalid_body)   { Article.create(body: 'shortbody') }
    let(:invalid_status) { Article.create(status: 'invalid_status') }

    it 'article is valid with valid attributes' do
      expect(article).to be_valid
    end

    it 'article is invalid with invalid body' do
      expect(invalid_body).not_to be_valid
    end

    it 'article gives errors for invalid body' do
      expect(invalid_body.errors.full_messages_for(:body)).to match(['Body is too short (minimum is 10 characters)'])
    end

    it 'article is invalid with invalid status' do
      expect(invalid_status).not_to be_valid
    end

    it 'article gives errors for invalid status' do
      expect(invalid_status.errors.full_messages_for(:status)).to match(['Status is not included in the list'])
    end
  end

  context 'when identical articles are created' do
    let(:article) { build(:article, title: 'identical') }

    before { create(:article, title: 'identical') }

    it 'creating article with same title is invalid' do
      expect(article).to be_invalid
    end
  end
end
