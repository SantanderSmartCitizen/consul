class Admin::Gamification::RewardsController < Admin::Gamification::BaseController
  include Translatable

  before_action :load_reward, only: [:show, :edit, :update]

  load_and_authorize_resource :gamification
  load_and_authorize_resource :reward, class: "Gamification::Reward"

  def index
    @rewards = ::Gamification::Reward.all
  end

  def new
    @gamifications = Gamification.all
    @reward = ::Gamification::Reward.new(
      active: true,
      request_to_administrators: false
    )
  end

  def create
    @reward = ::Gamification::Reward.new(reward_params)
    @gamification = @reward.gamification

    if @reward.save
      redirect_to return_path(params[:gamification_reward][:return_to]), 
                  notice: t("flash.actions.create.gamification_reward")
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @reward.update(reward_params)
      redirect_to return_path(params[:gamification_reward][:return_to]), 
                  notice: t("flash.actions.update.gamification_reward")
    else
      render :edit
    end
  end

  def destroy
    if @reward.destroy
      flash[:notice] = t("flash.actions.destroy.gamification_reward")
    else
      flash[:error] = @reward.errors.full_messages.join(",")
    end

    redirect_to return_path(params[:return_to])
  end

  private

    def reward_params
      attributes = [:gamification_id, :minimum_score, :active, :request_to_administrators, 
          documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy],
          links_attributes: [:id, :label, :url, :_destroy]]
      params.require(:gamification_reward).permit(
        *attributes, translation_params(Gamification::Action)
      )
    end

    def load_reward
      @reward = ::Gamification::Reward.find(params[:id] || params[:reward_id])
    end

    def resource
      load_reward unless @reward
      @reward
    end

    def return_path (return_to)
      if return_to == "gamification"
        admin_gamification_path(@reward.gamification, :tab => "rewards")
      else
        admin_gamification_rewards_path()
      end
    end

end
