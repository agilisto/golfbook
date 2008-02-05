class CreateTourDates < ActiveRecord::Migration
  def self.up
    create_table :tour_dates do |t|
      t.references :tour
      t.references :course
      t.date :to_play_at, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :tour_dates
  end
end
