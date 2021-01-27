class Gamification::RewardsController  < ApplicationController

  helper_method :gamification_reward

  def show
    authorize! :request_reward, gamification_reward
    @gamification_requested_reward = Gamification::RequestedReward.new
  end

  def create_request
    authorize! :request_reward, gamification_reward
    params = {
      user: current_user,
      gamification_reward: gamification_reward
    }
    @gamification_requested_reward = Gamification::RequestedReward.new(params)
    if @gamification_requested_reward.save
      redirect_to gamification_reward_path(gamification_reward),
                  { flash: { info: t("dashboard.create_request.success") }}
    else
      flash.now[:alert] = @gamification_requested_reward.errors.full_messages.join("<br>")
      render :show
    end
  end

  private

    def gamification_reward
      @gamification_reward = Gamification::Reward.find(params[:id])
    end

end
