class DropIdFromCoursesUsers < ActiveRecord::Migration
  def self.up
    remove_column :courses_users, :id
  end

  def self.down
    add_column :courses_users, :id
  end
end
