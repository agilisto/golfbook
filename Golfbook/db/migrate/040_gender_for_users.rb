class GenderForUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :female, :boolean, :default => false
  end

  def self.down
    drop_column :users, :female
  end
end
