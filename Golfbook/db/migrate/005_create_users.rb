class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :facebook_uid, :null => false
      t.string :session_key
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
