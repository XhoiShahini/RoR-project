class BackfillAddXfdfMergedToDocuments < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    Document.unscoped.in_batches do |relation|
      relation.update_all xfdf_merged: false
      sleep(0.01)
    end
  end
end
