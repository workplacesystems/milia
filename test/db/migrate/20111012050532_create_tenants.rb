class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :account, index: true
      t.string :name

      t.timestamps
    end
    add_index :accounts, :name
  end
end
