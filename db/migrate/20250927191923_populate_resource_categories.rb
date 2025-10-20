class PopulateResourceCategories < ActiveRecord::Migration[8.0]
     def up
          [ "Documents", "Presentations", "Spreadsheets", "PDFs" ].each do |name|
               ResourceCategory.find_or_create_by!(name: name)
          end
     end

  def down
       ResourceCategory.where(name: [ "Documents", "Presentations", "Spreadsheets", "PDFs" ]).delete_all
  end
end
