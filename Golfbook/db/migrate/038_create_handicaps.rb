class CreateHandicaps < ActiveRecord::Migration
  def self.up
    create_table :handicaps do |t|
      t.column :value, :integer
      t.column :round_id, :integer
      t.column :user_id, :integer
      t.column :change, :integer

      t.timestamps
    end
    add_column :rounds, :holes, :integer
    add_column :rounds, :course_rating, :integer
    add_column :courses, :course_rating, :integer
  end

  def self.down
    remove_column :rounds, :holes
    remove_column :rounds, :course_rating
    remove_column :courses, :course_rating
    drop_table :handicaps
  end
end
