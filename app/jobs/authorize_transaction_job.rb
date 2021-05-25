class AuthorizeTransactionJob < ApplicationJob
  def perform(transaction)
    # A background job must be enqueued to process the transaction
    # (random transition to either approved or declined)
    rand > 0.5 ? transaction.approve : transaction.decline
    transaction.save!
    # A background job must be enqueued for sending an HTTP POST
    # notification to the notification_url as soon as the transaction is processed
    notify(transaction)
  end

  def notify(transaction)
    uri = URI(transaction.notification_url)
    Net::HTTP.post_form(uri, unique_id: transaction.uuid, amount: transaction.amount, status: transaction.status)
  end
end
