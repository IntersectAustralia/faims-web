FactoryGirl.define do
  factory :role do |f|
    f.sequence(:name) { |n| "role-#{n}" }
  end
end
