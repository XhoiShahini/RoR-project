# == Schema Information
#
# Table name: meetings
#
#  id           :uuid             not null, primary key
#  completed_at :datetime
#  starts_at    :datetime
#  state        :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :uuid             not null
#  host_id      :uuid             not null
#
# Indexes
#
#  index_meetings_on_account_id  (account_id)
#  index_meetings_on_host_id     (host_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'aasm'
class Meeting < ApplicationRecord
  include AASM
  acts_as_tenant :account
  belongs_to :host, class_name: "User"

  has_many :meeting_members
  has_many :participants, through: :meeting_members, source: :memberable, source_type: "Participant"
  has_many :documents
  has_many :signatures, through: :documents

  aasm(column: :state, logger: Rails.logger, timestamps: true) do
    state :created, initial: true, display: I18n.t("meetings.state.created")
    state :incomplete, display: I18n.t("meetings.state.incomplete")
    state :completed, display: I18n.t("meetings.state.completed")

    event :start do
      transitions from: :created, to: :incomplete
    end

    event :pause do
      transitions from: :incomplete, to: :created
    end

    event :complete do
      transitions from: :incomplete, to: :completed, after: :complete_meeting
    end
  end

  private

  def complete_meeting
  end
end
