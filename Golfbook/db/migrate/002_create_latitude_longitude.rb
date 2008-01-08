class CreateLatitudeLongitude < ActiveRecord::Migration
  def self.up
    add_column :courses, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :courses, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :courses, :latitude
    remove_column :courses, :longitude
  end
end
