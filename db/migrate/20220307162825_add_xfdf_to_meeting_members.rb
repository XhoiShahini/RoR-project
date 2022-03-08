class AddXfdfToMeetingMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :meeting_members, :xfdf, :text
    add_column :meeting_members, :xfdf_merged, :boolean, default: false
  end
end
