class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.references :account, index: true
      t.string :name

      t.timestamps
    end
  end
end
