class AddGoalsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :goal, :integer, :default => 0
  end

  def self.down
    remove_column :users, :goal
  end
end
