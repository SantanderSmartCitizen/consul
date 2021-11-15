class Gamification::RewardsController  < ApplicationController
  has_filters %w[gamification_rewards gamification_user_rankings gamification_user_actions], only: :index
  
  before_action :authenticate_user!
  before_action :load_gamification_reward, only: [:show, :create_request]

  load_and_authorize_resource only: [:index]
  #helper_method :resource_model, :resource_name
  respond_to :html, :js

  def index
    load_filtered_activity
  end

  def show
    authorize! :request_reward, @gamification_reward
    @gamification_requested_reward = Gamification::RequestedReward.new
  end

  def create_request
    authorize! :request_reward, @gamification_reward
    params = {
      user: current_user,
      gamification_reward: @gamification_reward
    }
    @gamification_requested_reward = Gamification::RequestedReward.new(params)
    if @gamification_requested_reward.save
      redirect_to gamification_reward_path(@gamification_reward),
                  { flash: { info: t("dashboard.create_request.success") }}
    else
      flash.now[:alert] = @gamification_requested_reward.errors.full_messages.join("<br>")
      render :show
    end
  end

  private

    def load_gamification_reward
      @gamification_reward = Gamification::Reward.find(params[:id])
    end

    def set_activity_counts
      @activity_counts = ActiveSupport::HashWithIndifferentAccess.new(
                          gamification_rewards: Gamification::Reward.active_for(current_user).count,
                          gamification_user_rankings: Gamification::UserRanking.where(user_id: current_user.id).sum(:score),
                          gamification_user_actions: Gamification::UserAction.where(user_id: current_user.id).count)
    end

    def load_filtered_activity
      set_activity_counts
      case params[:filter]
      when "gamification_rewards" then load_gamifications
      when "gamification_user_rankings" then load_gamification_user_rankings
      when "gamification_user_actions" then load_gamification_user_actions
      else load_available_activity
      end
    end

    def load_available_activity
      if @activity_counts[:gamification_rewards] > 0
        load_gamifications
        @current_filter = "gamification_rewards"
      elsif @activity_counts[:gamification_user_rankings] > 0
        load_gamification_user_rankings
        @current_filter = "gamification_user_rankings"
      elsif @activity_counts[:gamification_user_actions] > 0
        load_gamification_user_actions
        @current_filter = "gamification_user_actions"
      end
    end

    def load_gamification_user_rankings
      @gamification_user_rankings = ::Gamification::UserRanking.where(user_id: current_user.id).page(params[:page])
    end

    def load_gamification_user_actions
      @gamification_user_actions = ::Gamification::UserAction.where(user_id: current_user.id).order(created_at: :desc).page(params[:page])
    end

    def load_gamifications
      @gamifications = Gamification.all
    end

    # def resource_model
    #   Gamification::Reward
    # end

    # def resource_name
    #   "gamification_reward"
    # end
end
