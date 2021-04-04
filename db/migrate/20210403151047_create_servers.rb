class CreateServers < ActiveRecord::Migration[6.1]
  def change
    create_table :servers, id: :uuid do |t|
      t.string :domain
      t.string :admin_secret
      t.string :admin_key

      t.timestamps
    end
  end
end
