module Abilities
  class Administrator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Moderation.new(user)

      can :restore, Comment
      cannot :restore, Comment, hidden_at: nil

      can :restore, Debate
      cannot :restore, Debate, hidden_at: nil

      can :restore, Forum
      cannot :restore, Forum, hidden_at: nil

      can :restore, Proposal
      cannot :restore, Proposal, hidden_at: nil

      can :create, Legislation::Proposal
      can :show, Legislation::Proposal
      can :proposals, ::Legislation::Process

      can :restore, Legislation::Proposal
      cannot :restore, Legislation::Proposal, hidden_at: nil

      can :restore, Budget::Investment
      cannot :restore, Budget::Investment, hidden_at: nil

      can :restore, User
      cannot :restore, User, hidden_at: nil

      can :confirm_hide, Comment
      cannot :confirm_hide, Comment, hidden_at: nil

      can :confirm_hide, Debate
      cannot :confirm_hide, Debate, hidden_at: nil

      can :confirm_hide, Forum
      cannot :confirm_hide, Forum, hidden_at: nil

      can :confirm_hide, Proposal
      cannot :confirm_hide, Proposal, hidden_at: nil

      can :confirm_hide, Legislation::Proposal
      cannot :confirm_hide, Legislation::Proposal, hidden_at: nil

      can :confirm_hide, Budget::Investment
      cannot :confirm_hide, Budget::Investment, hidden_at: nil

      can :confirm_hide, User
      cannot :confirm_hide, User, hidden_at: nil

      can :mark_featured, Debate
      can :unmark_featured, Debate

      can :mark_featured, Forum
      can :unmark_featured, Forum

      can :comment_as_administrator, [Debate, Forum, Comment, Proposal, Poll::Question, Budget::Investment,
                                      Legislation::Question, Legislation::Proposal, Legislation::Annotation, Topic]

      can [:search, :create, :index, :destroy, :edit, :update], ::Administrator
      can [:search, :create, :index, :destroy], ::Moderator
      can [:search, :show, :edit, :update, :create, :index, :destroy, :summary], ::Valuator
      can [:search, :edit, :update, :create, :index, :destroy], ::Manager
      can [:search, :edit, :update, :create, :index, :destroy], ::User

      can :manage, Dashboard::Action

      can [:index, :read, :new, :create, :update, :destroy, :calculate_winners], Budget
      can [:read, :create, :update, :destroy], Budget::Group
      can [:read, :create, :update, :destroy], Budget::Heading
      can [:hide, :admin_update, :toggle_selection], Budget::Investment
      can [:valuate, :comment_valuation], Budget::Investment
      cannot [:admin_update, :toggle_selection, :valuate, :comment_valuation],
        Budget::Investment, budget: { phase: "finished" }

      can :create, Budget::ValuatorAssignment

      can :read_admin_stats, Budget, &:balloting_or_later?
      can :read_final_admin_stats, Budget, &:finished?

      can [:search, :edit, :update, :create, :index, :destroy], Banner

      can [:search, :edit, :update, :create, :index, :destroy], HeaderSlide

      can [:search, :edit, :update, :create, :index, :destroy], Event

      can [:index, :create, :edit, :update, :destroy], Geozone
      can [:index, :create, :edit, :update, :destroy], BudgetGeozone

      can [:read, :create, :update, :destroy, :add_question, :search_booths, :search_officers, :booth_assignments], Poll
      can [:read, :create, :update, :destroy, :available], Poll::Booth
      can [:search, :create, :index, :destroy], ::Poll::Officer
      can [:create, :destroy, :manage], ::Poll::BoothAssignment
      can [:create, :destroy], ::Poll::OfficerAssignment
      can [:read, :create, :update], Poll::Question
      can :destroy, Poll::Question

      can :manage, SiteCustomization::Page
      can :manage, SiteCustomization::Image
      can :manage, SiteCustomization::ContentBlock

      can :access, :ckeditor
      can :manage, Ckeditor::Picture

      can [:manage], ::Legislation::Process
      can [:manage], ::Legislation::DraftVersion
      can [:manage], ::Legislation::Question
      can [:manage], ::Legislation::Proposal
      cannot :comment_as_moderator, [::Legislation::Question, Legislation::Annotation, ::Legislation::Proposal]

      can [:create], Document
      can [:destroy], Document, documentable_type: "Poll::Question::Answer"
      can [:create, :destroy], DirectUpload

      can [:deliver], Newsletter, hidden_at: nil
      can [:manage], Dashboard::AdministratorTask

      can :manage, LocalCensusRecord
      can [:create, :read], LocalCensusRecords::Import

      can [:read, :create, :update, :destroy, :add_action], Gamification
      can [:read, :create, :update, :update_operations, :search], Gamification::Action
      can :destroy, Gamification::Action
      can [:read, :create, :update], Gamification::Reward
      can :destroy, Gamification::Reward
      can [:read, :update], Gamification::RequestedReward

      can [:read, :create, :update, :destroy], Terminal
    end
  end
end
