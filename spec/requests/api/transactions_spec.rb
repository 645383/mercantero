require 'rails_helper'

RSpec.describe "/api/transactions", type: :request do
  let(:valid_attributes) {
    {
      type: transaction_type,
      amount: 99.99,
      uuid: 'uuid',
      customer_email: 'email@example.com',
      customer_phone: '+380960610359',
      notification_url: notification_url,
      parent_transaction_id: parent_transaction_id
    }
  }
  let(:transaction_type) { 'authorize' }
  let(:merchant) { create(:merchant) }
  let(:parent_transaction_id) { nil }
  let(:notification_url) { nil }

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
      let(:notification_url) { 'https://notificaton.example.com' }

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
        let(:parent_transaction_id) { create(:authorize_transaction, amount: parent_transaction_amount, status: 'approved').id }
        let(:transaction_type) { 'capture' }
        let(:parent_transaction_amount) { 99.99 }

        it 'creates transaction with status approved' do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

          expect(response_body['status']).to eq('approved')
        end

        context 'when Authorize transaction is pending' do
          let(:parent_transaction_id) { create(:authorize_transaction, amount: parent_transaction_amount, status: 'pending').id }

          it 'returns error' do
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

            expect(response_body['errors']).to eq([{ "parent_transaction" => ["Parent transaction should have status approved or captured"] }])
          end
        end

        context 'when Authorize transaction is captured' do
          let(:parent_transaction_id) { create(:authorize_transaction, amount: parent_transaction_amount, status: 'captured').id }

          it 'creates transaction with status approved' do
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

            expect(response_body['status']).to eq('approved')
          end
        end

        context 'when transaction amount is more than authorized' do
          let(:parent_transaction_amount) { 9.99 }

          it 'returns error' do
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

            expect(response_body['errors']).to eq([{ 'base' => ["Captured amount is more than authorized amount"] }])
          end
        end
      end

      context 'when creating Refund transaction' do
        let(:parent_transaction_id) { create(:capture_transaction, amount: parent_transaction_amount, status: status).id }
        let(:transaction_type) { 'refund' }
        let(:parent_transaction_amount) { 99.99 }
        let(:status) {'approved'}

        it 'creates transaction with status approved' do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

          expect(response_body['status']).to eq('approved')
        end

        context 'when Capture transaction has status error' do
          let(:status) {'error'}

          it 'returns error' do
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

            expect(response_body['errors']).to eq([{ "parent_transaction" => ["Parent transaction should have status approved or refunded"] }])
          end
        end

        context 'when Capture transaction is refunded' do
          let(:status) {'refunded'}

          it 'creates transaction with status approved' do
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

            expect(response_body['status']).to eq('approved')
          end
        end

        context 'when refund transaction amount is more than captured amount' do
          let(:parent_transaction_amount) { 9.99 }

          it 'returns error' do
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

            expect(response_body['errors']).to eq([{ 'base' => ["Refunded amount is more than captured amount"] }])
          end
        end
      end

      context 'when creating Void transaction' do
        let(:parent_transaction_id) { create(:authorize_transaction, status: status).id }
        let(:transaction_type) { 'void' }
        let(:status) {'approved'}

        it 'creates transaction with status approved' do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

          expect(response).to have_http_status(:created)
        end

        context 'when Authorize transaction has status error' do
          let(:status) {'error'}

          it 'returns error' do
            post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header

            expect(response_body['errors']).to eq([{ "parent_transaction" => ["Parent transaction should have status approved"] }])
          end
        end
      end
    end
  end
end
