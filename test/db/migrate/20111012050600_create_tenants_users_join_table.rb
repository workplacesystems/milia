class CreateAccountsUsersJoinTable < ActiveRecord::Migration
  def change
    create_join_table :accounts, :users do |t|
      t.index [:account_id, :user_id]
      # t.index [:user_id, :account_id]
    end
  end
end
