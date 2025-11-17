class RemoveResourceForeignKeyFromResourceVersions < ActiveRecord::Migration[8.0]
     def change
          remove_foreign_key :resource_versions, :resources
     end
end
