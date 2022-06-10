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
      get articles_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'contains all created articles in json response' do
      expect(parsed_response.map { |ar| ar['title'] }).to match_array(['First Title', 'Second Title', 'Third Title'])
    end
  end

  describe 'GET /show' do
    let(:article)    { create(:article) }
    let(:invalid_id) { "99" }

    context 'with valid article' do
      before { get article_path(article) }

      it { expect(response).to have_http_status(:ok) }
      it { expect(parsed_response['title']).to eq(article.title) }
      it { expect(parsed_response['body']).to eq(article.body) }
      it { expect(parsed_response['status']).to eq(article.status) }
    end

    context 'with invalid article id' do
      before { get article_path(invalid_id) }

      it 'returns 404 not found when article id not present' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /create' do
    context 'with valid article attributes verify article creation' do
      before { post articles_path, params: { article: valid_article_attributes } }

      it { expect(response).to have_http_status(:created) }
      it { expect(parsed_response['title']).to eq(valid_article_attributes[:title]) }
      it { expect(parsed_response['body']).to eq(valid_article_attributes[:body]) }
      it { expect(parsed_response['status']).to eq(valid_article_attributes[:status]) }
    end

    context 'with invalid article attributes verify article creation' do
      before { post articles_path, params: { article: invalid_article_attributes } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(parsed_response['body']).to include(/too short/) }
      it { expect(parsed_response['status']).to include(/is not included in the list/) }
    end
  end

  describe 'PUT /update' do
    let(:article) { create(:article) }

    context 'with valid article attributes verify article updation' do

      before { put article_path(article), params: { article: valid_article_attributes } }

      it { expect(response).to have_http_status(:ok)}
      it { expect(parsed_response['title']).to eq(valid_article_attributes[:title]) }
      it { expect(parsed_response['body']).to eq(valid_article_attributes[:body]) }
      it { expect(parsed_response['status']).to eq(valid_article_attributes[:status]) }
    end

    context 'with invalid article attributes verify article updation' do
      before { put article_path(article), params: { article: invalid_article_attributes } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(parsed_response['body']).to include(/too short/) }
      it { expect(parsed_response['status']).to include(/is not included in the list/) }
    end
  end

  describe 'DELETE /destroy' do
    context 'verify article deletion' do
      let(:article) { create(:article) }

      before { delete article_path(article) }

      it 'returns http no_content and deletes article' do
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'GET /index?tag_id=<tag_id>' do
    let(:tag)    { create(:tag, title: 'Common Tag Title') }
    let(:titles) { %w[First Second Third] }

    before do
      titles.each do |t|
        create(:article, title: "#{t} title")
        Article.last.tags << tag
      end
      # Create extra article to validate count
      create(:article, title: 'Dummy article')
    end
    
    context 'with multiple articles with same tag' do
      before { get articles_path, params: { tag_id: tag.id } }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'has the same count as the number of tagged articles' do
        expect(parsed_response.count).to eq titles.count
      end

      it 'does not have the same count as the total num of articles' do
        expect(parsed_response.count).not_to eq Article.count
      end

      it 'returns the correct tagged articles' do
        parsed_response.each_with_index do |res, idx|
          expect(res['title']).to eq("#{titles[idx]} title")
          expect(res['body']).to eq('Sample body which is long')
        end      
      end
    end
  end
end
