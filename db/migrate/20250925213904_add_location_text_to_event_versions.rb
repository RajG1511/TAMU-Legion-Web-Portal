class AddLocationTextToEventVersions < ActiveRecord::Migration[8.0]
     def change
          add_column :event_versions, :location_text, :string
     end
end
