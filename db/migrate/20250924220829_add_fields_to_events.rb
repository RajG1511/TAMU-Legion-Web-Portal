class AddFieldsToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :published, :integer, default: 0, null: false
    add_column :events, :location_type, :string
    add_column :events, :campus_code, :string
    add_column :events, :campus_number, :integer
    add_column :events, :location_name, :text
    add_column :events, :address, :text
    add_column :events, :image, :string
    
    add_index :events, :published
  end
end
