class ChangeTourDescription < ActiveRecord::Migration
  def self.up
    remove_column :tours, :description
    add_column :tours, :description, :text
  end

  def self.down
    remove_column :tours, :description
    add_column :tours, :description, :string
  end
end
