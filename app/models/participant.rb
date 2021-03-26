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
#  meeting_id          :uuid             not null
#
# Indexes
#
#  index_participants_on_meeting_id  (meeting_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_id => meetings.id)
#
class Participant < ApplicationRecord
  include UserAgreements
  has_person_name

  belongs_to :meeting
  has_one :meeting_member, as: :memberable
  has_one_attached :identification
end
