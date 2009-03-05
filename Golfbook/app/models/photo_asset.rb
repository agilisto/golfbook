class PhotoAsset < ActiveRecord::Base
  #the idea is to have users, rounds and courses be assets
  belongs_to :photo
  belongs_to :asset, :polymorphic => true

  validates_presence_of :photo_id, :asset_id, :asset_type

end
