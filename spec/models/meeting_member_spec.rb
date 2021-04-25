# == Schema Information
#
# Table name: meeting_members
#
#  id              :uuid             not null, primary key
#  company         :string
#  janus_token     :string
#  memberable_type :string           not null
#  must_sign       :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  company_id      :uuid
#  meeting_id      :uuid             not null
#  memberable_id   :uuid             not null
#
# Indexes
#
#  index_meeting_members_on_company_id  (company_id)
#  index_meeting_members_on_meeting_id  (meeting_id)
#  index_meeting_members_on_memberable  (memberable_type,memberable_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_id => meetings.id)
#
require 'rails_helper'

RSpec.describe MeetingMember, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
