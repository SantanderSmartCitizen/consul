FactoryBot.define do
  factory :gamification_requested_reward, class: 'Gamification::RequestedReward' do
    gamification_reward nil
    user nil
    executed_at "2020-12-10 13:13:23"
  end
end
