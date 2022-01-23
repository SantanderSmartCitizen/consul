class Admin::StatsController < Admin::BaseController

  before_action :load_budget, only: [:budget_supporting, :budget_balloting, :participation, :results, :comparative]
  before_action :load_stats, only: [:participation, :results, :comparative]

  def show
    @event_types = Ahoy::Event.pluck(:name).uniq.sort

    @visits    = Visit.count
    @debates   = Debate.with_hidden.count
    @forums    = Forum.with_hidden.count
    @proposals = Proposal.with_hidden.count
    @comments  = Comment.not_valuations.with_hidden.count

    @debate_votes     = Vote.where(votable_type: "Debate").count
    @milestone_votes  = Vote.where(votable_type: "Milestone").count
    @forum_votes      = Vote.where(votable_type: "Forum").count
    @proposal_votes   = Vote.where(votable_type: "Proposal").count
    @comment_votes    = Vote.where(votable_type: "Comment").count

    @votes = Vote.count

    @user_level_two   = User.active.level_two_verified.count
    @user_level_three = User.active.level_three_verified.count
    @verified_users   = User.active.level_two_or_three_verified.count
    @unverified_users = User.active.unverified.count
    @users = User.active.count

    @user_ids_who_voted_proposals = ActsAsVotable::Vote.where(votable_type: "Proposal")
                                                       .distinct
                                                       .count(:voter_id)

    @user_ids_who_didnt_vote_proposals = @verified_users - @user_ids_who_voted_proposals
    budgets_ids = Budget.where.not(phase: "finished").pluck(:id)
    @budgets = budgets_ids.size
    @investments = Budget::Investment.where(budget_id: budgets_ids).count
  end

  def graph
    @name = params[:id]
    @event = params[:event]

    if params[:event]
      @count = Ahoy::Event.where(name: params[:event]).count
    else
      @count = params[:count]
    end
  end

  def proposal_notifications
    @proposal_notifications = ProposalNotification.all
    @proposals_with_notifications = @proposal_notifications.select(:proposal_id).distinct.count
  end

  def direct_messages
    @direct_messages = DirectMessage.count
    @users_who_have_sent_message = DirectMessage.select(:sender_id).distinct.count
  end

  def budgets
    @budgets = Budget.order(id: :desc)
  end

  def budget_supporting
    heading_ids = @budget.heading_ids

    votes = Vote.where(votable_type: "Budget::Investment").
            includes(:budget_investment).
            where(budget_investments: { heading_id: heading_ids })

    @vote_count = votes.count
    @user_count = votes.select(:voter_id).distinct.count

    @voters_in_heading = {}
    @budget.headings.each do |heading|
      @voters_in_heading[heading] = voters_in_heading(heading)
    end
  end

  def budget_balloting
    authorize! :read_admin_stats, @budget, message: t("admin.stats.budgets.no_data_before_balloting_phase")

    @user_count = @budget.ballots.select { |ballot| ballot.lines.any? }.count

    @vote_count = @budget.lines.count

    @vote_count_by_heading = @budget.lines.group(:heading_id).count.map { |k, v| [Budget::Heading.find(k).name, v] }.sort

    # @user_count_by_district = User.where.not(balloted_heading_id: nil).group(:balloted_heading_id).count.map { |k, v| [Budget::Heading.find(k).name, v] }.sort
    @user_count_by_heading = @budget.lines.select("budget_ballots.user_id").group(:heading_id).distinct.count.map { |k, v| [Budget::Heading.find(k).name, v] }.sort

  end

  def participation
  end

  def results
    authorize! :read_final_admin_stats, @budget, message: t("admin.stats.budgets.no_data_before_results_phase")
  end

  def comparative
    authorize! :read_final_admin_stats, @budget, message: t("admin.stats.budgets.no_data_before_results_phase")
  end

  def polls
    @polls = ::Poll.only_users.current
    @participants = ::Poll::Voter.where(poll: @polls)
  end

  def poll_show
    @poll = ::Poll.find(params[:id])
  end

  def satisfaction_surveys
    @satisfaction_surveys = ::Poll.only_terminals

    question_ids = ::Poll::Question.where(poll: @satisfaction_surveys).pluck(:id)
    @total_votes = ::Poll::Answer.where(question_id: question_ids).count
  end

  def satisfaction_survey_show
    @satisfaction_survey = ::Poll.only_terminals.find(params[:id])
  end

  private

    def load_budget
      @budget = Budget.find(params[:budget_id])
    end

    def load_stats
      @stats = Budget::Stats.new(@budget)
    end

    def voters_in_heading(heading)
      Vote.where(votable_type: "Budget::Investment").
      includes(:budget_investment).
      where(budget_investments: { heading_id: heading.id }).
      select("votes.voter_id").distinct.count
    end
end
