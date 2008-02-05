class CreateTourPlayers < ActiveRecord::Migration
  def self.up
    create_table :tour_players do |t|
      t.references :user
      t.references :tour
      t.timestamps
    end
  end

  def self.down
    drop_table :tour_players
  end
end
