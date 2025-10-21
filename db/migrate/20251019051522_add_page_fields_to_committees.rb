class AddPageFieldsToCommittees < ActiveRecord::Migration[8.0]
     def change
          add_column :committees, :section1_heading, :string
       add_column :committees, :section1_body, :text
       add_column :committees, :section2_heading, :string
       add_column :committees, :section2_body, :text
     end
end
