class UsersCourses < ActiveRecord::Migration
  def self.up
     create_table :courses_users do |t|
        t.integer :user_id
        t.integer :course_id
        t.timestamps
      end
  end

  def self.down
    drop_table :courses_users
  end
end
