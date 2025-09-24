class AddFieldsToEventVersions < ActiveRecord::Migration[8.0]
  def change
    add_column :event_versions, :published, :integer
    add_column :event_versions, :location_type, :string
    add_column :event_versions, :campus_code, :string
    add_column :event_versions, :campus_number, :integer
    add_column :event_versions, :location_name, :text
    add_column :event_versions, :address, :text
    add_column :event_versions, :image, :string
  end
end
