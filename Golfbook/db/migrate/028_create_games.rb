class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.references :course
      t.references :user
      t.date :date_to_play
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
