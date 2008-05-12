class AddHolesAndPar < ActiveRecord::Migration
  def self.up
    add_column :courses, :holes, :integer
    add_column :courses, :par, :integer
  end

  def self.down
    remove_column :courses, :holes
    remove_column :courses, :par
  end
end
