# frozen_string_literal: true

class ArticlesController < ApplicationController
  skip_before_action :verify_authenticity_token
  ##
  # Retrieve all articles OR optionally pass 'tag_id' param to
  # Retrieve all aritlces with given 'tag_id'
  # GET /articles[?tag_id=<tag_id>]
  def index
    unless params[:tag_id]
      @articles = Article.all
    else
      @articles = Article.includes(:tags).where(tags: { id: params[:tag_id] })
    end
    render json: @articles
  end

  ##
  # Retrieve article by :id
  # GET /articles/:id
  def show
    @article = Article.find(params[:id])
    render json: @article
  end

  # ##
  # # Don't need for json-api currently
  # # Retrieve article by :id
  # # GET /articles/new
  # def new
  #   @article = Article.new
  # end
  
  ##
  # Create new article
  # POST /articles
  # JSON Data:
  # {
  #   "title": "Example Title",
  #   "body": "Example Body which is long"
  # }
  def create
    @article = Article.new(article_params)
    if @article.save
      render json: @article, status: :created
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # ##
  # # Don't need for json-api currently
  # # Edit article by :id
  # # GET /articles/:id/edit
  # def new
  #   @article = Article.new
  # end
  # def edit
  #   @article = Article.find(params[:id])
  # end

  ##
  # Edit article
  # PATCH/PUT /articles/:id
  # JSON Data:
  # {
  #   "title": "Example Title",
  #   "body": "Example Body which is long",
  #   "status": "public"
  # }
  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      render json: @article, status: :ok
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  ##
  # Destroy article
  # DELETE /articles/:id
  def destroy
    @article = Article.find(params[:id])

    if @article.destroy
      render json: { msg: "Deleted Article #{params[:id]} successfully!" }, status: :no_content
    else
      render json: @article, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
end
