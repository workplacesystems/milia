class CreateZines < ActiveRecord::Migration
  def change
    create_table :zines do |t|
      t.references :account, index: true
      t.references :team, index: true

      t.timestamps
    end
  end
end
