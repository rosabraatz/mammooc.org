FactoryGirl.define do
  factory :user_setting do
    sequence(:name) {|n| "my_setting_#{n}" }
    association :user, factory: :user
  end
end
