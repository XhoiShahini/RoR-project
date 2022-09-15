class AddCustomIdToMeetings < ActiveRecord::Migration[6.1]
  def change
    add_column :meetings, :custom_id, :string
  end
end
