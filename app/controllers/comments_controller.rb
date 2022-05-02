class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
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
    @article = Article.find_by_id(params[:article_id])
    @comment = @article.comments.create(comment_params)

    if @article and @comment.persisted?
      render json: {article: @article, article_comments: @article.comments}, status: :ok
    else
      render json: @article, status: :unprocessable_entity
    end
  end

  ##
  # Destroy comment on an article
  # DELETE /articles/:article_id/comments/:id
  def destroy
    @article = Article.find_by_id(params[:article_id])
    @comment = @article.comments.find_by_id(params[:id])

    if @article and @comment and @comment.destroy
      render json: {msg: "Deleted Comment #{params[:id]} successfully!"}, status: :ok
    else
      render json: @article, status: :unprocessable_entity
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status, :approval).with_defaults(approval: "submitted")
    end
  end
  