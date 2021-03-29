class AddStateToSignatures < ActiveRecord::Migration[6.1]
  def change
    add_column :signatures, :state, :string
  end
end
