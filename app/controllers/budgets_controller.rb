class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  feature_flag :budgets

  before_action :load_budget, only: :show
  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  before_action :load_investments, only: :index
  before_action :load_ballot, only: :index
  has_filters %w[not_unfeasible feasible unfeasible unselected selected winners], only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, "Not Found" unless budget_published?(@budget)
  end

  def index
    @finished_budgets = @budgets.finished.order(created_at: :desc)
    @budgets_coordinates = current_budget_map_locations
    @banners = Banner.in_section("budgets").with_active
    @header_slides = HeaderSlide.budgets
    @budget = current_budget
  end

  def previous
    @previous_budgets = Budget.previous(Budget.current.id)
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end

    def load_investments
      if params[:heading_id].present?
        @heading = current_budget.headings.find_by(id: params[:heading_id])
        if @heading.present?
          if current_budget.balloting_or_later? && current_budget.investments.selected.any?
            @investments = @heading.investments.selected.order(:title).page(params[:page]).per(10).for_render
          else
            @investments = @heading.investments.order(:title).page(params[:page]).per(10).for_render
          end
          
        else
          @investments = current_budget.investments.order(:title).page(params[:page]).per(10).for_render
        end
      else
        @investments = current_budget.investments.order(:title).page(params[:page]).per(10).for_render
      end
    end

    def load_ballot
      if current_budget.balloting? && user_signed_in?
        query = Budget::Ballot.where(user: current_user, budget: current_budget)
        @ballot = current_budget.balloting? ? query.first_or_create! : query.first_or_initialize
      end
    end
end
