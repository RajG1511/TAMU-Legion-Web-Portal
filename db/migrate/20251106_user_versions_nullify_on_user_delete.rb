# db/migrate/20251106_user_versions_nullify_on_user_delete.rb
class UserVersionsNullifyOnUserDelete < ActiveRecord::Migration[7.2]
  def up
    # allow nulls on user_id
    change_column_null :user_versions, :user_id, true

    # swap FK to ON DELETE SET NULL
    remove_foreign_key :user_versions, :users
    add_foreign_key :user_versions, :users, on_delete: :nullify
  end

  def down
    remove_foreign_key :user_versions, :users
    add_foreign_key :user_versions, :users # (default NO ACTION)
    change_column_null :user_versions, :user_id, false
  end
end

