# frozen_string_literal: true

class TagsController < ApplicationController
  skip_before_action :verify_authenticity_token
  ##
  # Retrieve all tags after filtering 
  # If `article_id` is provided, will limit search to that article only
  # GET /tags?query=<query>&optional_article_id=<optional_article_id>
  def index
    unless params[:article_id].nil?
      @tags = Article.find_by_id(params[:article_id]).tags.where("title LIKE ?", "%#{params[:query]}%")
    else
      @tags = Tag.where("title LIKE ?", "%#{params[:query]}%")
    end
    render json: @tags, status: :ok
  end

  ##
  # Retrieve tag by :id
  # GET /tags/:id
  def show
    @tag = Tag.find_by_id(params[:id])

    if @tag
      render json: @tag, status: :ok
    else
      render json: @tag, status: :unprocessable_entity
    end
  end
  
  ##
  # Create new tag ([optionally for an article])
  # POST /tags
  # JSON Data:
  # {
  #   "title": "Example Title",
  #   "counter": 1,
  #   "article_id": <article_id>    #Optional
  # }
  def create
    @article = Article.find_by_id(params[:article_id]) 

    if @article
      @tag = @article.tags.create(tag_params)
      if @tag.persisted?
        render json: @tag, status: :ok
      else
        render json: @tag.errors, status: :unprocessable_entity
      end
    else
      @tag = Tag.new(tag_params)
      if @tag.save
        render json: @tag, status: :ok
      else
        render json: @tag.errors, status: :unprocessable_entity
      end
    end
  end

  ##
  # Edit tag 
  # PATCH/PUT /tags/:id
  # JSON Data:
  # {
  #   "title": "Example Title",
  #   "counter": 1,
  #   "article_id": <article_id>    #Optional
  # }
  def update
    @article = Article.find_by_id(params[:article_id])
    @tag = Tag.find_by_id(params[:id])

    if @article
      if @tag and @tag.update(tag_params) and @article.tags.update(tag_params)
        render json: @tag, status: :ok
      else
        render json: @tag.errors, status: :unprocessable_entity
      end
    else
      if @tag and @tag.update(tag_params)
        render json: @tag, status: :ok
      else
        render json: @tag, status: :unprocessable_entity
      end
    end
  end

  ##
  # Destroy tag
  # DELETE /tag/:id
  def destroy
    @tag = Tag.find_by_id(params[:id])

    if @tag and @tag.destroy
      render json: {msg: "Deleted Tag #{params[:id]} successfully!"}, status: :ok
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  private
    def tag_params
      params.require(:tag).permit(:title)
    end
end
