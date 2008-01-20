class CreateRounds < ActiveRecord::Migration
  def self.up
    create_table :rounds do |t|
      t.integer :score
      t.date :date_played
      t.belongs_to :user
      t.belongs_to :course
      t.timestamps
    end
  end

  def self.down
    drop_table :rounds
  end
end
