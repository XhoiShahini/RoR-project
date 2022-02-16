class AddXfdfToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :xfdf, :text
  end
end
