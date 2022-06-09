# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe 'Tag requests', type: :request do
  let(:parsed_response)        { JSON.parse(response.body) }
  let(:article)                { create(:article) }
  let(:tag)                    { create(:tag) }
  let(:valid_tag_attributes)   { { title: 'valid' } }
  let(:invalid_tag_attributes) { { invalid_title: 'invalid' } }

  describe 'GET /index' do
    let(:first_article)  { create(:article, title: 'First article') }
    let(:second_article) { create(:article, title: 'Second article') }

    before do
      titles = %w[funny sad boring]
      # Attach 3 tags to first article
      titles.each do |title|
        first_article.tags << create(:tag, title: title.to_s)
      end
      # Create and attach 'common' tag to both articles
      first_article.tags << create(:tag, title: 'common')
      second_article.tags << create(:tag, title: 'common')
    end

    context 'no query and no article_id is passed ' do
      it 'returns http success and contains all created tags in json response' do
        get tags_path

        expect(response).to have_http_status(:ok)
        expect(parsed_response.map do |tag|
                 tag['title']
               end).to match_array(%w[funny sad boring common common])
      end
    end

    context 'query and no article_id is passed ' do
      it 'returns http success and contains all created tags filtered by query in json response' do
        get tags_path, params: { query: 'com' }

        expect(response).to have_http_status(:ok)
        expect(parsed_response.count).to eq(2)
        expect(parsed_response.first['title']).not_to include('sad')
        expect(parsed_response.map { |tag| tag['title'] }).to match_array(%w[common common])
      end
    end

    context 'query and article_id is passed ' do
      it 'returns http success and contains all created tags filtered by query belonging to article_id in json response' do
        get tags_path, params: { query: 'common', article_id: first_article.id }

        expect(response).to have_http_status(:ok)
        expect(parsed_response.count).to eq(1)
        expect(parsed_response.first['title']).not_to include('sad')
        expect(parsed_response.map { |tag| tag['title'] }).to match_array(['common'])
      end
    end
  end

  describe 'GET /show' do
    it 'returns http success and contains one created tag in json response' do
      get tag_path(tag)

      expect(response).to have_http_status(:ok)
      expect(parsed_response['title']).to eq(tag.title)
    end
  end

  describe 'POST /create' do
    context 'verify tag creation' do
      it 'returns http created and creates a new tag when valid attributes passed' do
        post tags_path, params: { tag: valid_tag_attributes }

        expect(response).to have_http_status(:created)
        expect(parsed_response['title']).to eq(valid_tag_attributes[:title])
      end

      it 'returns http unprocessable_entity and gives errors when invalid attributes passed' do
        post tags_path, params: { tag: invalid_tag_attributes }

        expect(response).to have_http_status(:unprocessable_entity)

        expect(parsed_response['title']).to include(/can't be blank/)
      end
    end
  end

  describe 'PUT /update' do
    context 'verify tag updation' do
      it 'returns http success and returns updated tag when valid attributes passed' do
        expect(tag.title).to eq('Sample title for tags')
        put tag_path(tag), params: { tag: valid_tag_attributes }

        expect(response).to have_http_status(:ok)
        expect(parsed_response['title']).to eq(valid_tag_attributes[:title])
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'verify tag deletion' do
      it 'returns http no_content and deletes article' do
        delete tag_path(tag)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'verify tag deletion when in use by article' do
      it 'returns an error and does not allow tag deletion' do
        article.tags << tag
        delete tag_path(tag)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response['base']).to eq ['cannot delete when currently used by Articles']
      end
    end
  end
end
