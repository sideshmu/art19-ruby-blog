# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  ##
  # Retrieve all approved comments for an article or optionally pass approval status
  # GET /articles/:article_id/comments[?approval=<approval>]
  def index
    @comments = Comment.where(
      article_id: params[:article_id],
      approval: params[:approval].presence || Comment::APPROVAL_STATUS_APPROVED
    )
    render json: @comments
  end

  ##
  # Create new comment on an article
  # POST /articles/:article_id/comments
  # JSON Data:
  # {
  #   "commenter": "Example Commenter",
  #   "body": "Example Comment Body",
  #   "status": "example status"
  # }
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)

    if @comment.persisted?
      # Process comment asynchronously
      ApprovalJob.perform_async(@comment.id)
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  ##
  # Update comment
  # PATCH/PUT /articles/:article_id/comments/:id
  # JSON Data:
  # {
  #   "commenter": "Example Commenter",
  #   "body": "Example Comment Body",
  #   "status": "Example Status"
  # }
  def update
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])

    if @comment.update(comment_params)
      ApprovalJob.perform_async(@comment.id)
      render json: @comment, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  ##
  # Destroy comment on an article
  # DELETE /articles/:article_id/comments/:id
  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])

    if @comment.destroy
      head :no_content
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:commenter, :body, :status).with_defaults(approval: 'submitted')
  end
end
