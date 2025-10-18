class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :location
      t.references :event_category, foreign_key: true
      t.integer :visibility, default: 0, null: false # 0 = public, 1 = members_only, 2 = execs_only

      t.timestamps
    end

    add_index :events, :starts_at
    add_index :events, :visibility
  end
end
