class AddCommitteeToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :committee, :string
  end
end
