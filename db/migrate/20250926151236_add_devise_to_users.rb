# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.0]
     def self.up
          change_table :users do |t|
               ## Database authenticatable
               # Remove this line because email already exists in your users table
               # t.string :email, null: false, default: ""
               t.string :encrypted_password, null: false, default: ""

            ## Recoverable
            t.string   :reset_password_token
            t.datetime :reset_password_sent_at

            ## Rememberable
            t.datetime :remember_created_at

               ## Trackable (optional)
               # t.integer  :sign_in_count, default: 0, null: false
               # t.datetime :current_sign_in_at
               # t.datetime :last_sign_in_at
               # t.string   :current_sign_in_ip
               # t.string   :last_sign_in_ip

               ## Confirmable (optional)
               # t.string   :confirmation_token
               # t.datetime :confirmed_at
               # t.datetime :confirmation_sent_at
               # t.string   :unconfirmed_email

               ## Lockable (optional)
               # t.integer  :failed_attempts, default: 0, null: false
               # t.string   :unlock_token
               # t.datetime :locked_at
          end

       # Keep the index on email if you don’t already have one
       # If your schema already has a unique index on email, comment this out too
       add_index :users, :email, unique: true unless index_exists?(:users, :email)
       add_index :users, :reset_password_token, unique: true
     end

  def self.down
       raise ActiveRecord::IrreversibleMigration
  end
end
