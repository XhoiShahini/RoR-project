class BackfillAddSignatureFieldsToDocuments < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    Document.unscoped.in_batches do |relation|
      relation.update_all signature_fields: {}
      sleep(0.01)
    end
  end
end
