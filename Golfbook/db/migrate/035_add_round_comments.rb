class AddRoundComments < ActiveRecord::Migration
  def self.up
    add_column :rounds, :comments, :text
  end

  def self.down
    remove_column :rounds, :comments
  end
end
