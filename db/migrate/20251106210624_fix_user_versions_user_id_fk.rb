# db/migrate/20251106_fix_user_versions_user_id_fk.rb
class FixUserVersionsUserIdFk < ActiveRecord::Migration[7.2]
  def up
    return unless table_exists?(:user_versions)

    # 1) allow NULLs (ignore if already nullable)
    begin
      change_column_null :user_versions, :user_id, true
    rescue StandardError
    end

    # 2) drop FK on user_id if it exists
    if foreign_key_exists?(:user_versions, :users, column: :user_id)
      remove_foreign_key :user_versions, column: :user_id
    end

    # 3) proactively null out orphans (defensive)
    execute <<~SQL
      UPDATE user_versions
         SET user_id = NULL
       WHERE user_id IS NOT NULL
         AND NOT EXISTS (SELECT 1 FROM users WHERE users.id = user_versions.user_id)
    SQL

    # 4) re-add FK with ON DELETE SET NULL
    add_foreign_key :user_versions, :users, column: :user_id, on_delete: :nullify

    # (optional) make sure there’s an index
    add_index :user_versions, :user_id unless index_exists?(:user_versions, :user_id)
  end

  def down
    return unless table_exists?(:user_versions) && column_exists?(:user_versions, :user_id)

    remove_foreign_key :user_versions, column: :user_id if foreign_key_exists?(:user_versions, :users, column: :user_id)
    add_foreign_key :user_versions, :users, column: :user_id # (default RESTRICT)
    # change_column_null :user_versions, :user_id, false  # only if you really want to revert nullability
  end
end

