class ValidateMeetingsServersFkey < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :meetings, :servers
  end
end
