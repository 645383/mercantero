class AuthorizeTransactionJob < ApplicationJob
  def perform(transaction)
    rand > 0.5 ? transaction.approve : transaction.decline
    transaction.save!
    notify(transaction)
  end

  def notify(transaction)
    uri = URI(transaction.notification_url)
    Net::HTTP.post_form(uri, unique_id: transaction.uuid, amount: transaction.amount, status: transaction.status)
  end
end
