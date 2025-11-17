class AddChangeTypeToEventVersions < ActiveRecord::Migration[8.0]
     def change
          add_column :event_versions, :change_type, :string
     end
end
