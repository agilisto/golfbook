class RenameHomeCourseField < ActiveRecord::Migration
  def self.up
    rename_column(:users, :course_id, :home_course_id)
  end

  def self.down
    rename_column(:users, :home_course_id, :course_id)
  end
end
