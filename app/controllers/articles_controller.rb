class ArticlesController < ApplicationController
  skip_before_action :verify_authenticity_token
  ##
  # Retrieve all articles
  # GET /articles/
  def index
    @articles = Article.all
    render json: @articles, status: :ok
  end

  ##
  # Retrieve article by :id
  # GET /articles/:id
  def show
    @article = Article.find_by_id(params[:id])

    if @article
      render json: @article, status: :ok
    else
      render json: @article, status: :unprocessable_entity
    end
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
      render json: @article, status: :ok
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
    @article = Article.find_by_id(params[:id])

    if @article and @article.update(article_params)
      render json: @article, status: :ok
    else
      render json: @article, status: :unprocessable_entity
    end
  end

  ##
  # Destroy article
  # DELETE /articles/:id
  def destroy
    @article = Article.find_by_id(params[:id])

    if @article and @article.destroy
      render json: {msg: "Deleted Article #{params[:id]} successfully!"}, status: :ok
    else
      render json: @article, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
end
