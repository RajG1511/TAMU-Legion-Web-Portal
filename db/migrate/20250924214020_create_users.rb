class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :graduation_year
      t.string :major
      t.string :t_shirt_size
      t.integer :status, default: 1, null: false # 1 = active
      t.string :position
      t.integer :role, default: 0, null: false # 0 = nonmember, 1 = member, 2 = exec, 3=pres
      t.string :image_url

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
    add_index :users, :status
  end
end
