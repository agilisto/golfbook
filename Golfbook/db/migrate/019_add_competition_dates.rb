class AddCompetitionDates < ActiveRecord::Migration
  def self.up
    add_column :competitions, :start_date, :date 
    add_column :competitions, :end_date, :date 
  end

  def self.down
    remove_column :competitions, :start_date
    remove_column :competitions, :end_date
  end

end
