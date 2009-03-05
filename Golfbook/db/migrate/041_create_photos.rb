class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.column :fb_album_id, :string
      t.column :fb_photo_id, :string
      t.column :user_id, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
