class Tour < ActiveRecord::Base
  belongs_to :user
  has_many :tour_dates
  has_many :tour_players
  has_many :courses, :through => :tour_dates
  has_many :users, :through => :tour_players
end
