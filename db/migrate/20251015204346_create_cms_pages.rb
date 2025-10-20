# db/migrate/xxxxxxxxxxxxxx_create_cms_pages.rb
class CreateCmsPages < ActiveRecord::Migration[7.1]
     def change
          # PAGES
          create_table :pages do |t|
               t.string :slug, null: false
            t.string :title
            t.timestamps
          end
       add_index :pages, :slug, unique: true

       # PAGE VERSIONS
       create_table :page_versions do |t|
            t.references :page, null: false, foreign_key: true
         t.references :user, null: false, foreign_key: true
         t.string :slug
         t.string :title
         t.string :change_type, null: false # "create", "update"
         t.timestamps
       end

       # SECTIONS
       create_table :sections do |t|
            t.references :page, null: false, foreign_key: true
         t.integer :position, null: false
         t.timestamps
       end
       add_index :sections, [ :page_id, :position ], unique: true

       # SECTION VERSIONS
       create_table :section_versions do |t|
            t.references :section, null: false, foreign_key: true
         t.references :page_version, null: false, foreign_key: true
         t.references :user, null: false, foreign_key: true
         t.integer :position, null: false
         t.text :content_html
         t.string :change_type, null: false # "create", "update"
         t.timestamps
       end
       add_index :section_versions, [ :section_id, :id ]
     end
end
