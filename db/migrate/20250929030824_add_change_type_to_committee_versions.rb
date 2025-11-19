class AddChangeTypeToCommitteeVersions < ActiveRecord::Migration[8.0]
     def change
          add_column :committee_versions, :change_type, :string
     end
end
