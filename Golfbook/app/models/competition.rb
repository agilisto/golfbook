class Competition < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :competitors
  has_many :users, :through => :competitors
end
