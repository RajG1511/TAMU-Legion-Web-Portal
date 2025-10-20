class CreateResources < ActiveRecord::Migration[8.0]
     def change
          create_table :resources do |t|
               t.string :name, null: false
            t.text :content
            t.integer :visibility, default: 0, null: false # 0 = public, 1 = members_only, 2 = execs_only
            t.references :resource_category, foreign_key: true

            t.timestamps
          end

       add_index :resources, :visibility
     end
end
