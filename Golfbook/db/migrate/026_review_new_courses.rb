class ReviewNewCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :awaiting_review, :bool, :default => false
    add_column :courses, :added_by, :integer
    add_column :users, :admin, :bool, :default => false
  end

  def self.down
    remove_column :courses, :awaiting_review
    remove_column :courses, :added_by
    remove_column :users, :admin
  end
end
