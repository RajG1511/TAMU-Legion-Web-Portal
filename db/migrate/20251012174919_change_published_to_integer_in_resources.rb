class ChangePublishedToIntegerInResources < ActiveRecord::Migration[8.0]
     def up
          execute <<-SQL
      ALTER TABLE resources
      ALTER COLUMN published DROP DEFAULT,
      ALTER COLUMN published TYPE integer USING CASE
        WHEN published = true THEN 1
        WHEN published = false THEN 0
        ELSE 0
      END,
      ALTER COLUMN published SET DEFAULT 0,
      ALTER COLUMN published SET NOT NULL;
    SQL
     end

  def down
       execute <<-SQL
      ALTER TABLE resources
      ALTER COLUMN published DROP DEFAULT,
      ALTER COLUMN published TYPE boolean USING CASE
        WHEN published = 1 THEN true
        WHEN published = 0 THEN false
        ELSE false
      END,
      ALTER COLUMN published SET DEFAULT false,
      ALTER COLUMN published SET NOT NULL;
    SQL
  end
end
