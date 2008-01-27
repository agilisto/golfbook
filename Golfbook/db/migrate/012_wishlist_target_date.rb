class WishlistTargetDate < ActiveRecord::Migration
  def self.up
    add_column :wishlists, :target_date, :date
  end

  def self.down
    remove_column :wishlists, :target_date
  end
end
