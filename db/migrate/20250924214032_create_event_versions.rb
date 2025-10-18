class CreateEventVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :event_versions do |t|
      t.string :name
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :location
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :visibility

      t.timestamps
    end
  end
end
