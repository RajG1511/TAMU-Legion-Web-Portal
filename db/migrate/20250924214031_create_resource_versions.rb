class CreateResourceVersions < ActiveRecord::Migration[8.0]
     def change
          create_table :resource_versions do |t|
               t.string :name
            t.text :content
            t.integer :visibility
            t.references :resource, null: false, foreign_key: true
            t.references :user, null: false, foreign_key: true

            t.timestamps
          end
     end
end
