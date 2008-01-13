class AddUserLocationFields < ActiveRecord::Migration
  def self.up
    add_column :users, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :users, :longitude, :decimal, :precision => 15, :scale => 10
    add_column :users, :address, :string
  end

  def self.down
    remove_column :users, :latitude
    remove_column :users, :longitude
    remove_column :users, :address
  end
 
end
