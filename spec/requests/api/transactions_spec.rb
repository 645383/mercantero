require 'rails_helper'

RSpec.describe "/api/transactions", type: :request do
  let(:valid_attributes) {
    {
      amount: 99.99,
      uuid: 'uuid',
      customer_email: 'email@example.com',
      customer_phone: '+380960610359',
      notification_url: 'https://notificaton.example.com'
    }
  }

  let(:invalid_attributes) {
  }

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Transaction" do
        expect {
          post transactions_url, params: { transaction: valid_attributes }
        }.to change(Transaction, :count).by(1)
      end
    end
  end
end
