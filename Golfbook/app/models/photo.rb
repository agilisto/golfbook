class Photo < ActiveRecord::Base
  has_many :photo_assets


  def assets
    PhotoAsset.find(:all, :conditions => ['photo_id = ?',self.id]).collect{|x|x.asset}.flatten.compact.uniq
  end

  def has_asset?(asset)
    PhotoAsset.find(:first, :conditions => ['photo_id = ? AND asset_type = ? and asset_id = ?',self.id, asset.class.name, asset.id])
  end

end
