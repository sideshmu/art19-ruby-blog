# frozen_string_literal: true

class TaggingsController < ApplicationController
  skip_before_action :verify_authenticity_token
  ##
  # Retrieve all taggings
  # GET /taggings
  def index
    @taggings = Tagging.all
    render json: @taggings
  end

  ##
  # Retrieve tagging by :id
  # GET /taggings/:id
  def show
    @tagging = Tagging.find(params[:id])
    render json: @tagging
  end
  
  ##
  # Create new tagging
  # POST /taggings
  # JSON Data:
  # {
  #   "article_id": "<article_id>",
  #   "tag_id": "<tag_id>"
  # }
  def create
    @tagging = Tagging.new(tagging_params)
    if @tagging.save
      render json: @tagging, status: :created
    else
      render json: @tagging.errors, status: :unprocessable_entity
    end
  end

  ##
  # Edit tagging
  # PATCH/PUT /taggings/:id
  # JSON Data:
  # {
  #   "article_id": "<article_id>",
  #   "tag_id": "<tag_id>"
  # }
  def update
    @tagging = Tagging.find(params[:id])

    if @tagging.update(tagging_params)
      render json: @tagging, status: :ok
    else
      render json: @tagging.errors, status: :unprocessable_entity
    end
  end

  ##
  # Destroy tagging
  # DELETE /taggings/:id
  def destroy
    @tagging = Tagging.find(params[:id])

    if @tagging.destroy
      render json: { msg: "Deleted tagging #{params[:id]} successfully!" }, status: :no_content
    else
      render json: @tagging.errors, status: :unprocessable_entity
    end
  end

  private
    def tagging_params
      params.require(:tagging).permit(:article_id, :tag_id)
    end
end
