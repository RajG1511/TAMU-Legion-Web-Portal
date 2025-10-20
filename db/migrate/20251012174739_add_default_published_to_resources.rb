class AddDefaultPublishedToResources < ActiveRecord::Migration[8.0]
     def change
          change_column_default :resources, :published, from: nil, to: 0
     end
end
