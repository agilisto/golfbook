class Review < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true
  
  # NOTE: Reviews belong to a user
  belongs_to :user
  
  cattr_reader :per_page
  @@per_page = 3
  
  # Helper class method to lookup all reviews assigned
  # to all reviewable types for a given user.
  def self.find_reviews_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
end