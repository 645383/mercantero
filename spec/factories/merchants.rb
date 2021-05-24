FactoryBot.define do
  factory :merchant do
    role
    name { Faker::Name.name  }
    description  { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    status { 'active' }
  end
end
