# db/migrate/20251108202925_create_announcements.rb
class CreateAnnouncements < ActiveRecord::Migration[8.0]
     def up
          create_table :announcements, if_not_exists: true do |t|
               t.text :message
            t.timestamps
          end
     end

  def down
       drop_table :announcements, if_exists: true
  end
end
