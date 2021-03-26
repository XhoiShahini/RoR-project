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
require 'rails_helper'

RSpec.describe Participant, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
