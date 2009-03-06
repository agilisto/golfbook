class PhotoAsset < ActiveRecord::Base
  #the idea is to have users, rounds and courses be assets
  belongs_to :photo
  belongs_to :asset, :polymorphic => true

  validates_presence_of :photo_id, :asset_id, :asset_type

  def self.photos_for(asset, num = 8)
    find(:all, :order => 'photo_assets.created_at desc', :conditions => ['asset_type = ? and asset_id = ?',asset.class.name, asset.id], :limit => num, :include => :photo).collect{|x|x.photo}
  end

end
