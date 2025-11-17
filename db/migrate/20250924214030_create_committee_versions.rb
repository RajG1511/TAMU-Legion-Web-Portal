class CreateCommitteeVersions < ActiveRecord::Migration[8.0]
     def change
          create_table :committee_versions do |t|
               t.string :name
            t.text :description
            t.references :committee, null: false, foreign_key: true
            t.references :user, null: false, foreign_key: true

            t.timestamps
          end
     end
end
