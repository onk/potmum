# frozen_string_literal: true

class LobbiesController < ApplicationController
  before_action :set_page

  # GET /
  # 新着順のエイリアス
  def root
    newest
  end

  # GET /newest
  # 新着順
  def newest
    @mode = :newest
    @articles = Article.public_items.includes(:user, :tags).page(@page)
    render :root
  end

  # GET /popular
  # 人気順
  def popular
    @mode = :popular
    article_ids = Article.top_ids({ stocks: 2, views: 1 }, months: 1)
    @paginated_article_ids = Kaminari.paginate_array(article_ids).page(@page)
    # If article is changed to draft, article_ids includes articles that should not be displayed.
    @articles = Article.public_item.where(id: @paginated_article_ids)
    render :root
  end

  # GET /comments
  # 新着コメント一覧
  def comments
    @mode = :comments
    @comments = Comment.recent(current_user).includes(:user, :article).page(@page)
    render :root
  end

  # GET /search
  # 検索結果
  def search
    @search_result = SearchArticleService.new.call(
      access_token: current_access_token,
      query: params[:q].to_s.strip[0..64],
      page: @page
    )
  end

  # GET /redirect?url=:url
  # リダイレクタ
  def redirector
    @url = params[:url].to_s.strip[0, 255]
    raise Errors::BadRequest unless @url.match?(%r{\Ahttps?://.+})
  end

  # GET /browserconfig.xml
  def browserconfig
    raise Errors::NotFound unless params[:format] == 'xml'
    render layout: nil
  end
end
