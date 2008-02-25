class AddCompetitionStatus < ActiveRecord::Migration
  def self.up
    add_column :competitions, :open, :bool, :default => true
  end

  def self.down
    remove_column :competitions, :open
  end
end
