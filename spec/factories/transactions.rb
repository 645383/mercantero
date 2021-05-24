FactoryBot.define do
  factory :transaction do
    merchant
    uuid { Faker::Internet.uuid }
    amount { Faker::Number.decimal }
    status { 'pending' }
    customer_email { Faker::Internet.email }
    customer_phone { Faker::PhoneNumber.phone_number }
    notification_url { Faker::Internet.url }
  end

  factory :authorize_transaction, parent: :transaction, class: 'Transaction::Authorize' do
  end

  factory :capture_transaction, parent: :transaction, class: 'Transaction::Capture' do
    status { 'approved' }
  end
end
