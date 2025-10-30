class RemoveEventForeignKeyFromEventVersions < ActiveRecord::Migration[8.0]
     def change
          remove_foreign_key :event_versions, :events
     end
end
