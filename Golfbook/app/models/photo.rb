class Photo < ActiveRecord::Base
  has_many :photo_assets
  belongs_to :user

  cattr_reader :per_page
  @@per_page = 20


  def assets
    PhotoAsset.find(:all, :conditions => ['photo_id = ?',self.id]).collect{|x|x.asset}.flatten.compact.uniq
  end

  def has_asset?(asset)
    PhotoAsset.find(:first, :conditions => ['photo_id = ? AND asset_type = ? AND asset_id = ?',self.id, asset.class.name, asset.id])
  end

  def courses
    PhotoAsset.find(:all, :conditions => ["photo_id = ? and asset_type = 'Course'",self.id]).collect{|x|x.asset}.flatten.compact.uniq
  end

  def rounds
    PhotoAsset.find(:all, :conditions => ["photo_id = ? and asset_type = 'Round'",self.id]).collect{|x|x.asset}.flatten.compact.uniq
  end

  def users
    PhotoAsset.find(:all, :conditions => ["photo_id = ? and asset_type = 'User'",self.id]).collect{|x|x.asset}.flatten.compact.uniq
  end

end
