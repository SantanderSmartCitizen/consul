class Admin::Gamification::RewardsController < Admin::Gamification::BaseController
  include Translatable

  load_and_authorize_resource :gamification
  load_and_authorize_resource :reward, class: "Gamification::Reward"

  def index
  end

  def new
  end

  def create
   if @reward.save
      redirect_to admin_gamification_path(@gamification)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

    def reward_params
      attributes = [:gamification_id, :reward]
      params.require(:reward).permit(*attributes, translation_params(Gamification::Reward))
    end

    def search_params
      params.permit(:gamification_id, :search)
    end

    def resource
      @reward ||= Gamification::Reward.find(params[:id])
    end
end
