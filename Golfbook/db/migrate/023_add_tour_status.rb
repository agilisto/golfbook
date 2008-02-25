class AddTourStatus < ActiveRecord::Migration
  def self.up
    add_column :tours, :open_for_entry, :bool, :default => true
  end

  def self.down
    remove_column :tours, :open_for_entry
  end
end
