class CreateCaddies < ActiveRecord::Migration
  def self.up
    create_table :caddies do |t|
      t.column :course_id, :integer
      t.column :first_name, :string
      t.column :last_name, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :caddies
  end
end
