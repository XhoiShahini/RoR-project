class AddJanusTokenToMeetingMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :meeting_members, :janus_token, :string
  end
end
