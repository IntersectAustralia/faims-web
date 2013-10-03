# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_module do |f|
    f.sequence(:name) { |n| "Module #{n}" }
    f.sequence(:key) { |n| SecureRandom.uuid }
  end
end
