class AddSignedMemberIdToMeetingMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :meeting_members, :signed_member_id, :string
  end
end
