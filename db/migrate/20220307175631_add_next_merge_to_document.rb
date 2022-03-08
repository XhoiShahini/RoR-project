class AddNextMergeToDocument < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :next_merge, :string
  end
end
