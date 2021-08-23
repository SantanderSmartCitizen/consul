class Admin::Gamification::RequestedRewardsController < Admin::Gamification::BaseController
  has_filters %w[pending done]

  helper_method :requested_reward

  def index
    authorize! :index, ::Gamification::RequestedReward
    @requested_rewards = ::Gamification::RequestedReward.send(@current_filter)
  end

  def edit
    authorize! :edit, requested_reward
  end

  def update
    authorize! :update, requested_reward

    requested_reward.update!(administrator_id: current_user.id, executed_at: Time.current)
    redirect_to admin_gamification_requested_rewards_path,
                { flash: { notice: t("admin.gamification.requested_rewards.update.success") }}
  end

  private

    def requested_reward
      @requested_reward ||= ::Gamification::RequestedReward.find(params[:id])
    end
end
