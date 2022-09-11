class ChangeIsAsyncDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :meetings, :is_async, from: false, to: true 
  end
end
