FactoryBot.define do
  factory :gamification_additional_score, class: 'Gamification::AdditionalScore' do
    gamification_action nil
    process_id 1
    additional_score 1
  end
end
