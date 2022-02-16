class AddXfdfMergedToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :xfdf_merged, :boolean, default: false
  end
end
