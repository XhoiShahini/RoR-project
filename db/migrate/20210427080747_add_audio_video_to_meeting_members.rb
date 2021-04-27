class AddAudioVideoToMeetingMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :meeting_members, :audio, :boolean, default: true
    add_column :meeting_members, :video, :boolean, default: true
  end
end
