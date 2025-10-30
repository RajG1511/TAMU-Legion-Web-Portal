class CreateCommittees < ActiveRecord::Migration[8.0]
     def change
          create_table :committees do |t|
               t.string :name
            t.text :description

            t.timestamps
          end
     end
end
