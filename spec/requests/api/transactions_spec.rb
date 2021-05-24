require 'rails_helper'

RSpec.describe "/api/transactions", type: :request do
  let(:valid_attributes) {
    {
      type: transaction_type,
      amount: 99.99,
      uuid: 'uuid',
      customer_email: 'email@example.com',
      customer_phone: '+380960610359',
      notification_url: 'https://notificaton.example.com'
    }
  }
  let(:transaction_type) {'authorize'}
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
        it 'creates transaction with status pending' do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

          expect(response_body['status']).to eq('pending')
        end

        it 'enqueues a job' do
          expect {
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
          }.to have_enqueued_job(AuthorizeTransactionJob)
        end
      end

      context 'when creating Capture transaction' do
        let(:transaction_type) {'capture'}

        it 'creates transaction with status approve' do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

          expect(response_body['status']).to eq('approved')
        end

        it 'does not enqueue a job' do
          expect {
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
          }.not_to have_enqueued_job(AuthorizeTransactionJob)
        end
      end
    end
  end
end
