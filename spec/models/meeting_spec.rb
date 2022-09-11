# == Schema Information
#
# Table name: meetings
#
#  id           :uuid             not null, primary key
#  completed_at :datetime
#  is_async     :boolean          default(TRUE)
#  starts_at    :datetime
#  state        :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :uuid             not null
#  host_id      :uuid             not null
#  server_id    :uuid
#
# Indexes
#
#  index_meetings_on_account_id  (account_id)
#  index_meetings_on_host_id     (host_id)
#  index_meetings_on_server_id   (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (server_id => servers.id)
#
require 'rails_helper'

RSpec.describe Meeting, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
