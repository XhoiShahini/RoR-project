class AddCompanyToMeetingMember < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :meeting_members, :company, :string
      add_reference :meeting_members, :company, type: :uuid
    end
  end
end
