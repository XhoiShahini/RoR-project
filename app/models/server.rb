# == Schema Information
#
# Table name: servers
#
#  id           :uuid             not null, primary key
#  admin_key    :string
#  admin_secret :string
#  domain       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Server < ApplicationRecord
end
