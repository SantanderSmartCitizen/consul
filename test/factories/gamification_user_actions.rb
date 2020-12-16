FactoryBot.define do
  factory :gamification_user_action, class: 'Gamification::UserAction' do
    user nil
    gamification_action nil
    action_score 1
    process_id 1
    additional_score 1
  end
end
