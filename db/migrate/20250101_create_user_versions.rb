class CreateUserVersions < ActiveRecord::Migration[7.1]
     def change
          create_table :user_versions do |t|
               t.integer :change_type, null: false, default: 0
            t.references :user,        null: false, foreign_key: true          # actor
            t.references :target_user, null: false, foreign_key: { to_table: :users }
            t.string  :summary, null: false
            t.jsonb   :details, null: false, default: {}
            t.timestamps
          end
       add_index :user_versions, :created_at
     end
end
