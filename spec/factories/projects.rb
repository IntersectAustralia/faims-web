# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do |f|
    f.sequence(:name) { |n| "Project #{n}" }
  end
end
