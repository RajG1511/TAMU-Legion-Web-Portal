class PopulateEventCategories < ActiveRecord::Migration[8.0]
     def up
          categories = [
            "Service",
            "Brotherhood",
            "Recruitment",
            "Social"
          ]

         categories.each do |name|
              EventCategory.find_or_create_by!(name: name)
         end
       end

  def down
       categories = [
         "Service",
         "Brotherhood",
         "Recruitment",
         "Social"
       ]

    EventCategory.where(name: categories).delete_all
  end
end
