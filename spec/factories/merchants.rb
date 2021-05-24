FactoryBot.define do
  factory :merchant do
    name { Faker::Name.name  }
    description  { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    status { 'active' }
  end
end
