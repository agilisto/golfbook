class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.column :user_id, :integer
      t.column :target_type, :string
      t.column :target_id, :integer
      t.column :verb, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
