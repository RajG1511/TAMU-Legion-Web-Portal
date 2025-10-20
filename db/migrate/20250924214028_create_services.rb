class CreateServices < ActiveRecord::Migration[8.0]
     def change
          create_table :services do |t|
               t.references :user, null: false, foreign_key: true
            t.decimal :hours, precision: 5, scale: 2, null: false
            t.string :name, null: false
            t.text :description
            t.date :date_performed, null: false
            t.integer :status, default: 0, null: false # 0 = pending, 1 = approved, 2 = rejected

            t.timestamps
          end

       add_index :services, :status
       add_index :services, :date_performed
     end
end
