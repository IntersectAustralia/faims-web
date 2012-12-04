FactoryGirl.define do
  factory :user do |f|
    f.first_name "Fred"
    f.last_name "Bloggs"
    f.password "Pas$w0rd"
    f.sequence(:email) { |n| "#{n}@intersect.org.au" }
  end
end
