class CreateGamePlayers < ActiveRecord::Migration
  def self.up
    create_table :game_players do |t|
      t.references :game
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :game_players
  end
end
