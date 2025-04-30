class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.binary :password_hash
      t.binary :salt

      t.timestamps
    end
  end
end
