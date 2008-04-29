class FixCourseDesc < ActiveRecord::Migration
  def self.up
    add_column :courses, :desc_new, :text
    Course.transaction do
      Course.find(:all).each do |course|
        course.desc_new = course.description
        course.save!
      end
    end
    remove_column :courses, :description
    rename_column :courses, :desc_new, :description
  end

  def self.down
  end
end
