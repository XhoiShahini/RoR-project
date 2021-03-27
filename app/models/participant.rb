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
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :uuid             not null
#
# Indexes
#
#  index_participants_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'aasm'
class Participant < ApplicationRecord
  include AASM
  include UserAgreements
  has_person_name

  acts_as_tenant :account
  has_one :meeting_member, as: :memberable
  has_one :meeting, through: :meeting_member
  has_many :signatures, through: :meeting_member
  has_one_attached :identification

  aasm(column: :state, logger: Rails.logger) do
    state :invited, initial: true, display: I18n.t("participants.state.invited")
    state :accepted, display: I18n.t("participants.state.accepted")
    state :joined, display: I18n.t("participants.state.joined")
    state :finalized, display: I18n.t("participants.state.finalized")

    event :accept_invitation do
      transitions from: :invited, to: :accepted
    end

    event :join_meeting do
      transitions from: :accepted, to: :joined
    end

    event :finalize do
      transitions from: :joined, to: :finalized
    end
  end
end
