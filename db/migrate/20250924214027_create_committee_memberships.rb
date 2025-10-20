class CreateCommitteeMemberships < ActiveRecord::Migration[8.0]
     def change
          create_table :committee_memberships do |t|
               t.references :user, null: false, foreign_key: true
            t.references :committee, null: false, foreign_key: true

            t.timestamps
          end
     end
end
