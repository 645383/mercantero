require 'rails_helper'

RSpec.describe "/api/transactions", type: :request do
  let(:valid_attributes) {
    {
      type: 'authorize',
      amount: 99.99,
      uuid: 'uuid',
      customer_email: 'email@example.com',
      customer_phone: '+380960610359',
      notification_url: 'https://notificaton.example.com'
    }
  }
  let(:merchant) { create(:merchant) }

  let(:auth_header) {
    { 'Authorization' => "Bearer #{JWT.encode({ merchant_id: merchant.id }, Rails.configuration.x.jwt_secret)}" }
  }

  let(:invalid_attributes) {
  }

  describe "POST /create" do
    context 'when merchant is unauthorized' do
      context 'when auth token is not provided' do
        it "returns unauthorized error" do
          post api_transactions_url, params: { transaction: valid_attributes }

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when merchant is inactive" do
        let(:merchant) { create(:merchant, status: 'inactive') }

        it "returns unauthorized error" do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "with valid parameters" do
      it "creates a new Transaction" do
        expect {
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
        }.to change(Transaction, :count).by(1)
      end

      context 'when creating Authorize transaction' do
        post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
      end
    end
  end
end
