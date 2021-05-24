class Transaction::Capture < Transaction
  include Transactions::StateMachine::Capture
end