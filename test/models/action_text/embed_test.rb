# == Schema Information
#
# Table name: action_text_embeds
#
#  id         :uuid             not null, primary key
#  fields     :jsonb
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class ActionText::EmbedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
