FactoryBot.define do
  factory :merchant do
    name { Faker::Name.name  }
    description  { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    status { 'active' }
  end
end
