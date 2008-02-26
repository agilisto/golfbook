class OpenCloseEntriesComps < ActiveRecord::Migration
  def self.up
    add_column :competitions, :open_for_entry, :bool, :default => true
  end

  def self.down
    remove_column :competitions, :open_for_entry
  end
end
