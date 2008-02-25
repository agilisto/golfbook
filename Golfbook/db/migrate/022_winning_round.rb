class WinningRound < ActiveRecord::Migration
  def self.up
    add_column :competition_rounds, :winning_round, :bool, :default => false
  end

  def self.down
    remove_column :competition_rounds, :winning_round
  end
end
