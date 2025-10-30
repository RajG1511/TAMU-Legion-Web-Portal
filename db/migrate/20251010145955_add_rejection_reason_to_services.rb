class AddRejectionReasonToServices < ActiveRecord::Migration[8.0]
     def change
          add_column :services, :rejection_reason, :text
     end
end
