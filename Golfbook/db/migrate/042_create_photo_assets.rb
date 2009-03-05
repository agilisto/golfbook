class CreatePhotoAssets < ActiveRecord::Migration
  def self.up
    create_table :photo_assets do |t|
      t.column :asset_type, :string
      t.column :asset_id, :integer
      t.column :photo_id, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_assets
  end
end
