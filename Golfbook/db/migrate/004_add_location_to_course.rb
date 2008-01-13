class AddLocationToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :location_text, :string
  end

  def self.down
    remove_column :courses, :location_text
  end
end
