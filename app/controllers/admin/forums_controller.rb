class Admin::ForumsController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders

  feature_flag :forums

  has_orders %w[created_at]

  def show
    @forum = Forum.find(params[:id])
  end

  private

    def resource_model
      Forum
    end
end
