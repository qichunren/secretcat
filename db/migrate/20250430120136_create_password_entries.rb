class CreatePasswordEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :password_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :encrypted_data

      t.timestamps
    end
  end
end
