class AddServerToMeeting < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :meetings, :server, null: true, type: :uuid, index: {algorithm: :concurrently}
    add_foreign_key :meetings, :servers, validate: false
  end
end
