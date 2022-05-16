# frozen_string_literal: true

require "rails_helper"

RSpec.describe ArticlesController, type: :controller do
  let(:valid_article_attributes) do
    {
      title: "Test title", 
      body: "Test body which is long", 
      status: "public"
    }
  end

  let(:invalid_article_attributes) do
    {
      title: "Test title", 
      body: "shortbody", 
      status: "invalid_status"
    }
  end

  context "verify article creation" do
    let!(:article) { Article.create(valid_article_attributes) }
    it "article is valid with valid attributes" do
      expect(article).to be_valid 
    end

    let!(:invalid_article) { Article.create(invalid_article_attributes) }
    it "article is invalid with invalid attributes" do
        expect(invalid_article).not_to be_valid 
      end
  end

  context "verify uniqueness of article title" do
    let!(:article1) { Article.create(valid_article_attributes) }
    let!(:article2) { Article.create(valid_article_attributes) }
    it "article2 with same title is not created" do
      expect(article2).to be_invalid
    end
  end

  context "GET #index" do
    it "returns a success response" do
      get :index
      # expect(response.success).to eq(true)
      expect(response).to be_successful 
    end
  end

  context "GET #show" do
    let!(:article) { Article.create(valid_article_attributes) }

    it "returns a success response" do
      get :show, params: { id: 1 }
      expect(response).to be_successful
    end
  end
end