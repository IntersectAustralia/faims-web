FactoryGirl.define do
  factory :permission do |f|
    f.entity "MyEntity"
    f.action "MyAction"
  end
end
