# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :group do
    sequence(:name) {|n| "Gruppe #{n}" }
    description 'Lorem ipsum Bacon Soda.'
    users { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
  end
end
