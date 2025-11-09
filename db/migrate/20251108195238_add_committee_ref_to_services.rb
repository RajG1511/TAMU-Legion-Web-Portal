# db/migrate/20251108195238_add_committee_ref_to_services.rb
class AddCommitteeRefToServices < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:services, :committee_id)
      add_reference :services, :committee, foreign_key: true
    end

    if column_exists?(:services, :committee)
      remove_column :services, :committee, :string
    end
  end
end

