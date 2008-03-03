class ChangeAddedByColName < ActiveRecord::Migration
  def self.up
    remove_column :courses, :added_by
    add_column :courses, :added_by_id, :integer
  end

  def self.down
    remove_column :courses, :added_by_id
    add_column :courses, :added_by, :integer
  end
end
