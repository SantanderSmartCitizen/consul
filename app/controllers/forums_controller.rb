class ForumsController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions
  include Translatable

  before_action :authenticate_user!, except: [:index, :show, :map]
  before_action :set_view, only: :index
  before_action :forums_recommendations, only: :index, if: :current_user

  feature_flag :forums

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Forum.forums_orders(c.current_user) }, only: :index
  has_orders %w[most_voted newest oldest], only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def index_customization
    @featured_forums = @forums.featured
    @header_slides = HeaderSlide.forums
  end

  def show
    super
    @related_contents = Kaminari.paginate_array(@forum.relationed_contents).page(params[:page]).per(5)
    redirect_to forum_path(@forum), status: :moved_permanently if request.path != forum_path(@forum)
  end

  def vote
    @forum.register_vote(current_user, params[:value])
    set_forum_votes(@forum)
  end

  def unmark_featured
    @forum.update!(featured_at: nil)
    redirect_to forums_path
  end

  def mark_featured
    @forum.update!(featured_at: Time.current)
    redirect_to forums_path
  end

  def disable_recommendations
    if current_user.update(recommended_forums: false)
      redirect_to forums_path, notice: t("forums.index.recommendations.actions.success")
    else
      redirect_to forums_path, error: t("forums.index.recommendations.actions.error")
    end
  end

  private

    def forum_params
      attributes = [:tag_list, :terms_of_service]
      params.require(:forum).permit(attributes, translation_params(Forum))
    end

    def resource_model
      Forum
    end

    def set_view
      @view = (params[:view] == "minimal") ? "minimal" : "default"
    end

    def forums_recommendations
      if Setting["feature.user.recommendations_on_forums"] && current_user.recommended_forums
        @recommended_forums = Forum.recommendations(current_user).sort_by_random.limit(3)
      end
    end
end
