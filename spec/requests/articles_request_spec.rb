# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe 'Article requests', type: :request do
  let(:parsed_response) { JSON.parse(response.body) }

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

  describe 'GET /index' do
    before do
      titles = %w[First Second Third]
      titles.each { |t| create(:article, title: "#{t} Title") }
    end

    it 'returns http success and contains all created articles in json response' do
      get articles_path

      expect(response).to have_http_status(:ok)
      expect(parsed_response.map { |ar| ar['title'] }).to match_array(['First Title', 'Second Title', 'Third Title'])
    end
  end

  describe 'GET /show' do
    let(:article) { create(:article) }

    it 'returns http success and contains one created article in json response' do
      get article_path(article)

      expect(response).to have_http_status(:ok)
      expect(parsed_response['title']).to eq(article.title)
      expect(parsed_response['body']).to eq(article.body)
      expect(parsed_response['status']).to eq(article.status)
    end
  end

  describe 'POST /create' do
    context 'verify article creation' do
      it 'returns http created and creates a new article when valid attributes passed' do
        post articles_path, params: { article: valid_article_attributes }

        expect(response).to have_http_status(:created)

        expect(parsed_response['title']).to eq(valid_article_attributes[:title])
        expect(parsed_response['body']).to eq(valid_article_attributes[:body])
        expect(parsed_response['status']).to eq(valid_article_attributes[:status])
      end

      it 'returns http unprocessable entity and gives errors when invalid attributes passed' do
        post articles_path, params: { article: invalid_article_attributes }

        expect(response).to have_http_status(:unprocessable_entity)

        expect(parsed_response['body']).to include(/too short/)
        expect(parsed_response['status']).to include(/is not included in the list/)
      end
    end
  end

  describe 'PUT /update' do
    context 'verify article updation' do
      let(:article) { create(:article) }

      it 'returns http success and returns updated article when valid attributes passed' do
        put article_path(article), params: { article: valid_article_attributes }

        expect(response).to have_http_status(:ok)

        expect(parsed_response['title']).to eq(valid_article_attributes[:title])
        expect(parsed_response['body']).to eq(valid_article_attributes[:body])
        expect(parsed_response['status']).to eq(valid_article_attributes[:status])
      end

      it 'returns http unprocessable entity and gives errors when invalid attributes passed' do
        put article_path(article), params: { article: invalid_article_attributes }

        expect(response).to have_http_status(:unprocessable_entity)

        expect(parsed_response['body']).to include(/too short/)
        expect(parsed_response['status']).to include(/is not included in the list/)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'verify article deletion' do
      let(:article) { create(:article) }

      it 'returns http no_content and deletes article' do
        delete article_path(article)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'GET /index?tag_id=<tag_id>' do
    let(:tag)          { create(:tag, title: 'Common Tag Title') }
    let(:titles)       { %w[First Second Third] }

    before do
      titles.each do |t|
        create(:article, title: "#{t} title")
        Article.last.tags << tag
      end
      # Create extra article to validate count
      create(:article, title: 'Dummy article')
    end

    it 'returns http success and contains all articles with given tag_id' do
      get articles_path, params: { tag_id: tag.id }

      expect(response).to have_http_status(:ok)
      expect(parsed_response.count).to eq titles.count
      expect(parsed_response.count).not_to eq Article.count

      parsed_response.each_with_index do |res, idx|
        expect(res['title']).to eq("#{titles[idx]} title")
        expect(res['body']).to eq('Sample body which is long')
      end
    end
  end
end
