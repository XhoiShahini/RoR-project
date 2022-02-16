class AddXfdfMergedToDocuments < ActiveRecord::Migration[6.1]
  def up
    add_column :documents, :xfdf_merged, :boolean
    change_column_default :documents, :xfdf_merged, false
  end

  def down
    remove_column :documents, :xfdf_merged
  end
end
