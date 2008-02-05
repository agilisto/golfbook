class CreateTours < ActiveRecord::Migration
  def self.up
    create_table :tours do |t|
      t.references :user
      t.string :name, :null => false
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :tours
  end
end
