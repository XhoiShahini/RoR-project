class AddSignatureFieldsToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :signature_fields, :jsonb
    change_column_default :documents, :signature_fields, {}
  end

  def down
    remove_column :documents, :signature_fields
  end
end
