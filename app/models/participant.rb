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
class Participant < ApplicationRecord
  include UserAgreements
  has_person_name

  acts_as_tenant :account
  has_one :meeting_member, as: :memberable
  has_one :meeting, through: :meeting_member
  has_many :signatures, through: :meeting_member
  has_one_attached :identification
end
