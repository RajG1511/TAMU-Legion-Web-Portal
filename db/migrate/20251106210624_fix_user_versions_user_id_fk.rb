# db/migrate/20251106210624_fix_user_versions_user_id_fk.rb
class FixUserVersionsUserIdFk < ActiveRecord::Migration[7.2]
  def up
    return unless table_exists?(:user_versions)

    # If both :user_id and :actor_id exist, we only touch :user_id here.
    if column_exists?(:user_versions, :user_id)
      # Allow NULLs (ignore if constraint already dropped)
      begin
        change_column_null :user_versions, :user_id, true
      rescue StandardError
        # noop
      end

      # Remove the FK on user_id only (do NOT touch actor_id)
      if foreign_key_exists?(:user_versions, :users, column: :user_id)
        remove_foreign_key :user_versions, column: :user_id
      end

      # Clean any orphans defensively
      execute <<~SQL.squish
        UPDATE user_versions
           SET user_id = NULL
         WHERE user_id IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM users WHERE users.id = user_versions.user_id)
      SQL

      # Re-add FK with ON DELETE SET NULL
      add_foreign_key :user_versions, :users, column: :user_id, on_delete: :nullify

      add_index :user_versions, :user_id unless index_exists?(:user_versions, :user_id)
    end
  end

  def down
    return unless table_exists?(:user_versions) && column_exists?(:user_versions, :user_id)

    remove_foreign_key :user_versions, column: :user_id if foreign_key_exists?(:user_versions, :users, column: :user_id)
    add_foreign_key :user_versions, :users, column: :user_id
    # If you previously required NOT NULL, you could restore it here.
    # change_column_null :user_versions, :user_id, false
  end
end

