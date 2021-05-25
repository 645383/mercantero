module Transactions
  module StateMachine
    module Authorize
      extend ActiveSupport::Concern
      included do
        include AASM

        aasm column: 'status' do
          # The transaction should be created with status pending
          state :pending, initial: true
          state :approved
          state :captured
          state :voided
          state :error

          event :approve do
            transitions from: [:pending], to: :approved
          end

          event :capture do
            transitions from: [:approved, :captured], to: :captured
          end

          event :void do
            transitions from: [:approved], to: :voided
          end

          event :decline do
            transitions from: [:pending], to: :error
          end
        end
      end
    end

    module Capture
      extend ActiveSupport::Concern
      included do
        include AASM

        aasm column: 'status' do
          state :pending, initial: true
          state :approved
          state :refunded
          state :error

          event :approve do
            transitions from: [:pending], to: :approved
          end

          event :decline do
            transitions from: [:pending], to: :error
          end

          event :refund do
            transitions from: [:approved, :refunded], to: :refunded
          end
        end
      end
    end

    module Refund
      extend ActiveSupport::Concern
      included do
        include AASM

        aasm column: 'status' do
          state :pending, initial: true
          state :approved
          state :error

          event :approve do
            transitions from: [:pending], to: :approved
          end

          event :decline do
            transitions from: [:pending], to: :error
          end
        end
      end
    end

    module Void
      extend ActiveSupport::Concern
      included do
        include AASM

        aasm column: 'status' do
          state :pending, initial: true
          state :approved
          state :error

          event :approve do
            transitions from: [:pending], to: :approved
          end

          event :decline do
            transitions from: [:pending], to: :error
          end
        end
      end
    end
  end
end
