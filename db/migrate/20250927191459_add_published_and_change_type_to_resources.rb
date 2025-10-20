class AddPublishedAndChangeTypeToResources < ActiveRecord::Migration[8.0]
     def change
          add_column :resources, :published, :boolean, default: false, null: false
       add_column :resource_versions, :change_type, :string
       add_column :resource_versions, :published, :boolean, default: false, null: false
     end
end
