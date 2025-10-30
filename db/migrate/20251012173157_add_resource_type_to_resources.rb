class AddResourceTypeToResources < ActiveRecord::Migration[8.0]
     def change
          add_column :resources, :resource_type, :string

       say_with_time "Updating resource categories" do
            categories = {
              1 => "General",
              2 => "Member",
              3 => "PR",
              4 => "Conduct"
            }

             categories.each do |id, name|
                  ResourceCategory.where(id: id).update_all(name: name)
             end
       end
     end
end
