class AddResourceTypeToResourceVersions < ActiveRecord::Migration[8.0]
  def change
    add_column :resource_versions, :resource_type, :string
  end
end
