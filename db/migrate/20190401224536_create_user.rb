class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :email
      t.string :password_digest
      t.integer :role
      t.boolean :active

      t.timestamps
    end
  end
end
