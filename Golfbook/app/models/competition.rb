class Competition < ActiveRecord::Base
  belongs_to :user
  has_many :competitors
  has_many :users, :through => :competitors
end
