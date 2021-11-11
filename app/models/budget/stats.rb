class Budget::Stats
  include Statisticable
  alias_method :budget, :resource

  def self.stats_methods
    super + support_phase_methods + vote_phase_methods
  end

  def self.support_phase_methods
    %i[total_participants_support_phase total_budget_investments
       total_selected_investments total_unfeasible_investments headings]
  end

  def self.vote_phase_methods
    %i[total_votes total_participants_vote_phase]
  end

  def stats_methods
    base_stats_methods + participation_methods + phase_methods
  end

  def phases
    %w[support vote].select { |phase| send("#{phase}_phase_finished?") }
  end

  def all_phases
    return phases unless phases.many?

    [*phases, "every"]
  end

  def support_phase_finished?
    budget.valuating_or_later?
  end

  def vote_phase_finished?
    budget.finished?
  end

  def total_participants
    participants.distinct.count
  end

  def total_participants_support_phase
    voters.count
  end

  def total_participants_vote_phase
    (balloters + poll_ballot_voters).uniq.count
  end

  def total_budget_investments
    budget.investments.count
  end

  def total_votes
    budget.ballots.pluck(:ballot_lines_count).reduce(0) { |sum, x| sum + x }
  end

  def total_selected_investments
    budget.investments.selected.count
  end

  def total_feasible_investments
    budget.investments.feasible.count
  end

  def total_unfeasible_investments
    budget.investments.unfeasible.count
  end

  def total_citizen_investments
    budget.investments.by_user_profile_citizen.count
  end

  def total_city_hall_investments
    budget.investments.by_user_profile_city_hall.count
  end

  def total_investments_by_heading
    budget.headings.order("id ASC").map do |heading|
      {
        name: heading.name, 
        data: heading.investments.count
      }
    end
  end

  def total_investments_by_organization_name
    budget.investments.group(:organization_name).count.map do |name, data|
      {
        name: name, 
        data: data
      }
    end
  end

  def total_investments_by_civic_centers
    User.unscoped.civic_center.where(id: authors).map do |civic_center|
      {
        name: civic_center.username, 
        data: civic_center.budget_investments.by_budget(budget).count
      }
    end
  end

  def winning_investments_by_heading
    budget.headings.order("id ASC").map do |heading|
      {
        name: heading.name, 
        data: heading.investments.winners.count
      }
    end
  end

  def winning_investments_by_municipal_area
    MunicipalAreaAssignment.where(user_id: winner_authors).map do |municipal_area_assignment|
      {
        name: municipal_area_assignment.municipal_area.title, 
        data: budget.investments.winners.where(author_id: municipal_area_assignment.user.id).count
      }
    end
  end

  def headings_total_price
    budget.headings.sum(&:price)
  end

  def economic_effort_by_heading(headings_total_price)
    budget.headings.order("id ASC").map do |heading|
      [
        heading.name, 
        calculate_percentage(heading.price, headings_total_price)
      ]
    end
  end

  def economic_effort_of_winning_investments_by_heading(headings_total_price)
    budget.headings.order("id ASC").map do |heading|
      [
        heading.name, 
        calculate_percentage(heading.investments.winners.sum(&:price), headings_total_price)
      ]
    end
  end


  def total_headings_price_by_heading
    budget.headings.order("id ASC").map do |heading|
      [
        heading.name, 
        heading.price
      ]
    end
  end

  def total_winning_investments_price_by_heading
    budget.headings.order("id ASC").map do |heading|
      [
        heading.name, 
        heading.investments.winners.sum(&:price)
      ]
    end
  end

  def total_remaining_price_by_heading
    budget.headings.order("id ASC").map do |heading|
      [
        heading.name, 
        heading.price - heading.investments.winners.sum(&:price)
      ]
    end
  end

  def total_winner_investments_in_current_budget
    investments = budget.investments
    investments.winners.count
  end

  def total_nowinner_investments_in_current_budget
    investments = budget.investments
    investments.count - investments.winners.count
  end

  def total_previous_budget_investments
    budget.previous.investments.count
  end

  def total_winner_investments_in_previous_budget
    investments = budget.previous.investments
    investments.winners.count
  end

  def total_nowinner_investments_in_previous_budget
    investments = budget.previous.investments
    investments.count - investments.winners.count
  end

  def current_budget_year
    budget.year
  end

  def previous_budget_year
    budget.previous.year
  end

  def has_previous?
    budget.has_previous?
  end

  def total_investments_by_budget
    array = []

    if budget.has_previous?
      array.push([
        budget.previous.year,
        total_previous_budget_investments
      ])
    end

    array.push([
        budget.year, 
        total_budget_investments
    ])

    array
  end

  def total_winner_investments_by_budget
    array = []

    if budget.has_previous?
      array.push([
        budget.previous.year,
        total_winner_investments_in_previous_budget
      ])
    end

    array.push([
        budget.year, 
        total_winner_investments_in_current_budget
    ])

    array
  end

  def total_nowinner_investments_by_budget
    array = []

    if budget.has_previous?
      array.push([
        budget.previous.year,
        total_nowinner_investments_in_previous_budget
      ])
    end

    array.push([
        budget.year, 
        total_nowinner_investments_in_current_budget
    ])

    array
  end

  def total_winner_investments_by_budget_and_heading

    array = []

    budget_previous = budget.previous

    if budget_previous.present?

      budget_heading_names = budget_previous.heading_names | budget.heading_names

      array.push(
        {
          :name => budget_previous.year,
          :data => budget_heading_names.map do |heading_name|
            heading = budget_previous.headings.find_by(name: heading_name)
            if heading.present?
              [
                heading_name,
                heading.investments.winners.count
              ]
            else
              [
                heading_name,
                0
              ]
            end
          end
        }
      )
    else
      budget_heading_names = budget.heading_names
    end

    array.push(
      {
        :name => budget.year,
        :data => budget_heading_names.map do |heading_name|
          heading = budget.headings.find_by(name: heading_name)
          if heading.present?
            [
              heading_name,
              heading.investments.winners.count
            ]
          else
            [
              heading_name,
              0
            ]
          end
        end
      }
    )

    array
  end

  def total_investments_meets_feasibility_requirements
    budget.investments.meet_feasibility_requirements.count
  end

  def total_investments_not_meets_feasibility_requirements
    budget.investments.dont_meet_feasibility_requirements.count
  end

  def unfeasible_investments_by_unfeasibility_reason
    budget.investments.unfeasible.group(:unfeasibility_explanation).count.map do |key, count|
      {
        name: key ? key : I18n.t("stats.without_reason"),
        data: count
      }
    end
  end

  def budget_execution

    array = []

    budget_previous = budget.previous

    if budget_previous.present?
      budget_previous_price = budget_previous.headings.sum(&:price)
      budget_previous_investments_price = budget_previous.investments.winners.sum(&:price)
      array.push(
        {
          :name => budget_previous.year,
          :data => [
            [I18n.t("stats.budget"), budget_previous_price],
            [I18n.t("stats.estimated_engaged"), budget_previous_investments_price],
            [I18n.t("stats.remaining"), budget_previous_price - budget_previous_investments_price]
          ]
        }
      )
    end

    budget_price = budget.headings.sum(&:price)
    budget_investments_price = budget.investments.winners.sum(&:price)
    array.push(
      {
        :name => budget.year,
        :data => [
          [I18n.t("stats.budget"), budget_price],
          [I18n.t("stats.estimated_engaged"), budget_investments_price],
          [I18n.t("stats.remaining"), budget_price - budget_investments_price]
        ]
      }
    )

    array
  end

  def winning_investments_by_execution_status
    winning_investments = budget.investments.winners

    execution_status = Hash.new(0)
    winning_investments.each do |winning_investment|

      last_published_milestone = winning_investment.milestones.published.order_by_publication_date.last

      if last_published_milestone && last_published_milestone&.status&.name
        execution_status[last_published_milestone&.status&.name] += 1
      else
        execution_status["No ha comenzado"] += 1
      end

    end
    execution_status.map do |_k, v| {name: _k, data: v} end
  end

  def headings
    groups = Hash.new(0)
    budget.headings.order("id ASC").each do |heading|
      groups[heading.id] = Hash.new(0).merge(calculate_heading_totals(heading))
    end

    groups[:total] = Hash.new(0)
    groups[:total][:total_investments_count] = groups.map { |_k, v| v[:total_investments_count] }.sum
    groups[:total][:total_participants_support_phase] = groups.map { |_k, v| v[:total_participants_support_phase] }.sum
    groups[:total][:total_participants_vote_phase] = groups.map { |_k, v| v[:total_participants_vote_phase] }.sum
    groups[:total][:total_participants_every_phase] = groups.map { |_k, v| v[:total_participants_every_phase] }.sum

    budget.headings.each do |heading|
      groups[heading.id].merge!(calculate_heading_stats_with_totals(groups[heading.id], groups[:total], heading.population))
    end

    groups[:total][:percentage_participants_support_phase] = groups.map { |_k, v| v[:percentage_participants_support_phase] }.sum
    groups[:total][:percentage_participants_vote_phase] = groups.map { |_k, v| v[:percentage_participants_vote_phase] }.sum
    groups[:total][:percentage_participants_every_phase] = groups.map { |_k, v| v[:percentage_participants_every_phase] }.sum

    groups
  end

  private

    def phase_methods
      phases.map { |phase| self.class.send("#{phase}_phase_methods") }.flatten
    end

    def participant_ids
      phases.map { |phase| send("participant_ids_#{phase}_phase") }.flatten.uniq
    end

    def participant_ids_support_phase
      (authors + voters).uniq
    end

    def participant_ids_vote_phase
      (balloters + poll_ballot_voters).uniq
    end

    def authors
      @authors ||= budget.investments.pluck(:author_id)
    end

    def winner_authors
      @winner_authors ||= budget.investments.winners.pluck(:author_id)
    end

    def voters
      @voters ||= supports(budget).distinct.pluck(:voter_id)
    end

    def balloters
      @balloters ||= budget.ballots.where("ballot_lines_count > ?", 0).distinct.pluck(:user_id).compact
    end

    def poll_ballot_voters
      @poll_ballot_voters ||= budget.poll ? budget.poll.voters.pluck(:user_id) : []
    end

    def balloters_by_heading(heading_id)
      stats_cache("balloters_by_heading_#{heading_id}") do
        budget.ballots.joins(:lines)
                      .where(budget_ballot_lines: { heading_id: heading_id })
                      .distinct.pluck(:user_id)
      end
    end

    def voters_by_heading(heading)
      stats_cache("voters_by_heading_#{heading.id}") do
        supports(heading).distinct.pluck(:voter_id)
      end
    end

    def calculate_heading_totals(heading)
      {
        total_investments_count: heading.investments.count,
        total_participants_support_phase: voters_by_heading(heading).count,
        total_participants_vote_phase: balloters_by_heading(heading.id).count,
        total_participants_every_phase: voters_and_balloters_by_heading(heading)
      }
    end

    def calculate_heading_stats_with_totals(heading_totals, groups_totals, population)
      {
        percentage_participants_support_phase: participants_percent(heading_totals, groups_totals, :total_participants_support_phase),
        percentage_district_population_support_phase: population_percent(population, heading_totals[:total_participants_support_phase]),
        percentage_participants_vote_phase: participants_percent(heading_totals, groups_totals, :total_participants_vote_phase),
        percentage_district_population_vote_phase: population_percent(population, heading_totals[:total_participants_vote_phase]),
        percentage_participants_every_phase: participants_percent(heading_totals, groups_totals, :total_participants_every_phase),
        percentage_district_population_every_phase: population_percent(population, heading_totals[:total_participants_every_phase])
      }
    end

    def voters_and_balloters_by_heading(heading)
      (voters_by_heading(heading) + balloters_by_heading(heading.id)).uniq.count
    end

    def participants_percent(heading_totals, groups_totals, phase)
      calculate_percentage(heading_totals[phase], groups_totals[phase])
    end

    def population_percent(population, participants)
      return "N/A" unless population.to_f.positive?

      calculate_percentage(participants, population)
    end

    def supports(supportable)
      Vote.where(votable: supportable.investments)
    end

    stats_cache(*stats_methods)

    def stats_cache(key, &block)
      Rails.cache.fetch("budgets_stats/#{budget.id}/#{phases.join}/#{key}/#{version}", &block)
    end

end
