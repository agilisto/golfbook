class AddCoursesLocationFields < ActiveRecord::Migration
  def self.up
    add_column :courses, :locality, :string
    add_column :courses, :region, :string
    add_column :courses, :country, :string
    add_column :courses, :source_reference, :string
  end

  def self.down
    remove_column :courses, :locality
    remove_column :courses, :region
    remove_column :courses, :country
    remove_column :courses, :source_reference
  end
end
