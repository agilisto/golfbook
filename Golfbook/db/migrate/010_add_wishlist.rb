class AddWishlist < ActiveRecord::Migration
  def self.up
     create_table :wishlists do |t|
        t.date :target_date
        t.belongs_to :user
        t.belongs_to :course
        t.timestamps
      end
    end

    def self.down
      drop_table :wishlists
    end
end
