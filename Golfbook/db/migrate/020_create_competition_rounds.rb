class CreateCompetitionRounds < ActiveRecord::Migration
  def self.up
    create_table :competition_rounds do |t|
      t.references :competition
      t.references :round
      t.timestamps
    end
  end

  def self.down
    drop_table :competition_rounds
  end
end
