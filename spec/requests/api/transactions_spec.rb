require 'rails_helper'

RSpec.describe "/api/transactions", type: :request do
  let(:valid_attributes) {
    {
      type: transaction_type,
      amount: amount,
      uuid: 'uuid',
      customer_email: 'email@example.com',
      customer_phone: '+380960610359',
      notification_url: notification_url,
      parent_transaction_id: parent_transaction_id
    }
  }
  let(:amount) { 99.99 }
  let(:transaction_type) { 'authorize' }
  let(:merchant) { create(:merchant) }
  let(:notification_url) { nil }
  let(:parent_transaction) { create(parent_transaction_type, amount: parent_transaction_amount, status: parent_transaction_status) }
  let(:parent_transaction_type) { :authorize_transaction }
  let(:parent_transaction_id) { parent_transaction.id }
  let(:parent_transaction_amount) { 99.99 }
  let(:parent_transaction_status) { 'approved' }

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

    context 'when creating Authorize transaction' do
      let(:parent_transaction_id) { nil }
      let(:notification_url) { 'https://notificaton.example.com' }

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
      let(:transaction_type) { 'capture' }

      it "changes state of parent transaction to captured" do
        expect {
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
        }.to change { parent_transaction.reload.status }.from('approved').to('captured')
      end

      context 'when parent Authorize transaction' do
        before do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
        end

        context 'is approved' do
          let(:parent_transaction_status) { 'approved' }

          it 'creates a transaction with status approved' do
            expect(response).to have_http_status(:created)
            expect(response_body['status']).to eq('approved')
          end
        end

        context 'is captured' do
          let(:parent_transaction_status) { 'captured' }

          it 'creates transaction with status approved' do
            expect(response).to have_http_status(:created)
            expect(response_body['status']).to eq('approved')
          end
        end

        context 'is pending' do
          let(:parent_transaction_status) { 'pending' }

          it 'returns error' do
            expect(response_body['errors']).to eq([{ "parent_transaction" => ["Parent transaction should have status approved or captured"] }])
          end
        end

        context 'has status error' do
          let(:parent_transaction_status) { 'error' }

          it 'returns error' do
            expect(response_body['errors']).to eq([{ "parent_transaction" => ["Parent transaction should have status approved or captured"] }])
          end
        end

        context 'amount is less than to be captured' do
          let(:parent_transaction_amount) { 9.99 }

          it 'returns error' do
            expect(response_body['errors']).to eq([{ 'base' => ["Captured amount is more than authorized amount"] }])
          end
        end
      end
    end

    context 'when creating Refund transaction' do
      let(:transaction_type) { 'refund' }
      let(:parent_transaction_type) { :capture_transaction }

      it "changes state of parent transaction to captured" do
        expect {
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
        }.to change { parent_transaction.reload.status }.from('approved').to('refunded')
      end

      context 'when parent Capture transaction' do
        before do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
        end

        context 'is approved' do
          let(:parent_transaction_status) { 'approved' }

          it 'creates a transaction with status approved' do
            expect(response).to have_http_status(:created)
            expect(response_body['status']).to eq('approved')
          end
        end

        context 'is refunded' do
          let(:parent_transaction_status) { 'refunded' }

          it 'creates transaction with status approved' do
            expect(response).to have_http_status(:created)
            expect(response_body['status']).to eq('approved')
          end
        end

        context 'has status error' do
          let(:parent_transaction_status) { 'error' }

          it 'returns error' do
            expect(response_body['errors']).to eq([{ "parent_transaction" => ["Parent transaction should have status approved or refunded"] }])
          end
        end

        context 'amount is less than to be refunded' do
          let(:parent_transaction_amount) { 9.99 }

          it 'returns error' do
            expect(response_body['errors']).to eq([{ 'base' => ["Refunded amount is more than captured amount"] }])
          end
        end
      end
    end

    context 'when creating Void transaction' do
      let(:amount) { nil }
      let(:transaction_type) { 'void' }
      let(:parent_transaction_type) { :authorize_transaction }
      let(:parent_transaction_status) { 'approved' }

      context 'when parent Authorize transaction' do
        before do
          post api_transactions_url, params: { transaction: valid_attributes }, headers: auth_header
        end

        context 'is approved' do
          let(:parent_transaction_status) { 'approved' }

          it 'creates a transaction with status approved' do
            expect(response).to have_http_status(:created)
            expect(response_body['status']).to eq('approved')
          end
        end

        context 'has status error' do
          let(:parent_transaction_status) { 'error' }

          it 'returns error' do
            expect(response_body['errors']).to eq([{ "parent_transaction" => ["Parent transaction should have status approved"] }])
          end
        end
      end
    end
  end
end
