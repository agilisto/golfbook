class CreateCompetitors < ActiveRecord::Migration
  def self.up
    create_table :competitors do |t|
      t.references :user
      t.references :competition
      t.timestamps
    end
  end

  def self.down
    drop_table :competitors
  end
end
