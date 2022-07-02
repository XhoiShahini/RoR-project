class AddIsAsyncToMeetings < ActiveRecord::Migration[6.1]
  def change
    add_column :meetings, :is_async, :boolean, default: false
  end
end
