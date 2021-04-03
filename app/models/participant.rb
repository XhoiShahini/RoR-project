# == Schema Information
#
# Table name: participants
#
#  id                  :uuid             not null, primary key
#  accepted_privacy_at :datetime
#  accepted_terms_at   :datetime
#  email               :string
#  first_name          :string
#  last_name           :string
#  phone_number        :string
#  state               :string
#  verified_at         :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :uuid             not null
#  verifier_id         :uuid
#
# Indexes
#
#  index_participants_on_account_id   (account_id)
#  index_participants_on_verifier_id  (verifier_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'aasm'
class Participant < ApplicationRecord
  class Verification
    def initialize(participant, args = {})
      @participant = participant
      @verifier = args[:verifier]
      @verified_at = Time.now
    end
  
    def call
      @participant.update(verified_at: @verified_at, verifier: @verifier)
    end
  end
  include AASM
  include IdentificationAttached
  has_person_name

  acts_as_tenant :account
  belongs_to :verifier, class_name: "User", optional: true

  has_one :meeting_member, as: :memberable, dependent: :destroy
  has_one :meeting, through: :meeting_member
  has_many :signatures, through: :meeting_member
  has_many :sms_verifications, as: :sms_verifiable

  accepts_nested_attributes_for :meeting_member

  aasm(column: :state, logger: Rails.logger) do
    state :invited, initial: true, display: I18n.t("participants.state.invited")
    state :accepted, display: I18n.t("participants.state.accepted")
    state :verified, display: I18n.t("participants.state.verified")
    state :finalized, display: I18n.t("participants.state.finalized")

    event :accept do
      transitions from: :invited, to: :accepted
    end

    # Takes a verifier argument
    event :verify do
      transitions from: :accepted, to: :verified, after: Verification
    end

    event :finalize do
      transitions from: :joined, to: :finalized
    end
  end
end
