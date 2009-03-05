class Photo < ActiveRecord::Base
  has_many :photo_assets


  def assets
    PhotoAsset.find(:all, :conditions => ['photo_id = ?',self.id]).collect{|x|x.asset}.flatten.compact.uniq
  end

end
