# == Schema Information
#
# Table name: docs
#
#  id               :integer          not null, primary key
#  title            :string
#  body             :text
#  keywords         :string
#  title_tag        :string
#  meta_description :string
#  category_id      :integer
#  user_id          :integer
#  active           :boolean          default(TRUE)
#  rank             :integer
#  permalink        :string
#  version          :integer
#  front_page       :boolean          default(FALSE)
#  cheatsheet       :boolean          default(FALSE)
#  points           :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  topics_count     :integer          default(0)
#  allow_comments   :boolean          default(TRUE)
#  attachments      :string           default([]), is an Array
#

class DocsController < ApplicationController

  before_action :knowledgebase_enabled?, only: ['show']
  before_action :doc_available_to_view?, only: ['show']
  after_action  :is_user_signed_in?
  theme :theme_chosen

  respond_to :html

  def show
    # SEO improvement: we don't want 2 pages with same content to have different urls
    #   It is currently the case with category_doc_path and doc_path routes
    redirect_if_category_doc_url; return if performed?
    redirect_if_wrong_canonical_path; return if performed?
    define_topic_for_doc
    define_forum_for_docs
    generate_page_breadcumbs
  end

  private

  def doc_available_to_view?
    @doc = Doc.find_by(id: params[:id], active: true)
    redirect_to controller: 'errors', action: 'not_found' if @doc.nil? || !@doc.category.publicly_viewable?
  end

  def is_user_signed_in?
    @user = User.new unless user_signed_in?
  end

  def generate_page_breadcumbs
    add_breadcrumb t(:knowledgebase, default: "Knowledgebase"), categories_path

    @doc.category.path.each do |cat|
      add_breadcrumb cat.name, category_path(cat) if cat.name
    end
    add_breadcrumb @doc.title
    @page_title = @doc.title
  end

  def define_forum_for_docs
    @forum = Forum.for_docs.first
    @comment = @forum.topics.new unless @forum.nil?
  end

  def define_topic_for_doc
    if @doc.topic.present?
      @topic  = @doc.topic
      @post   = @topic.posts.new
      @posts  = @topic.posts.ispublic.chronologic.active.includes(:user) unless @topic.nil?
    else
      @topic  = Topic.new
      @post   = Post.new
    end
  end

  def redirect_if_category_doc_url
    if params[:category_id].present? && params[:id].present?
      redirect_to doc_path(params[:id]), status: :moved_permanently and return
    end
  end

  def redirect_if_wrong_canonical_path
    if request.path != doc_path(@doc)
      redirect_to doc_path(@doc), status: :moved_permanently and return
    end
  end
end
