class CreateEventCategories < ActiveRecord::Migration[8.0]
     def change
          create_table :event_categories do |t|
               t.string :name

            t.timestamps
          end
     end
end
