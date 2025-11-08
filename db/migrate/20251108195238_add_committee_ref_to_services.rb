class AddCommitteeRefToServices < ActiveRecord::Migration[8.0]
  def change
    add_reference :services, :committee, foreign_key: true
    remove_column :services, :committee, :string
  end
end
