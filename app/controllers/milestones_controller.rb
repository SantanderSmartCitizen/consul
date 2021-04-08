class MilestonesController < ApplicationController

  include CommentableActions
  include Translatable

  has_orders %w[most_voted newest oldest], only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    @commentable = @milestone
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    # @milestone_votes = daily_cache("milestone_votes") { Vote.where(votable_type: "Milestone").count }
  end

  def vote
    @milestone.register_vote(current_user, params[:value])
    set_milestone_votes(@milestone)
  end

  private
    def resource_model
      Milestone
    end

end
