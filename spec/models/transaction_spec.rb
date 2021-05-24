RSpec.describe Transaction do
  let(:authorize_transaction) { create(:authorize_transaction, status: 'approved')}
  let(:capture_transaction) { create(:capture_transaction, parent_transaction: authorize_transaction)}

  it 'creates transactions chain' do
    expect(capture_transaction.parent_transaction).to eq(authorize_transaction)
  end
end
