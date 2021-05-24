class Transaction::Authorize < Transaction
  include Transactions::StateMachine::Authorize
end