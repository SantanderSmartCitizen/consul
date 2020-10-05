class Admin::GamificationsController < Admin::BaseController

  def show
	@users = User.active.count
  end

  def budgets
    @budgets = Budget.all
  end

end
