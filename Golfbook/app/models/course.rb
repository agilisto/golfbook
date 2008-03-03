require 'hpricot'
require 'geonames'

class Course < ActiveRecord::Base
  
  belongs_to :added_by, :class_name => "User", :foreign_key => "added_by_id"
  
  has_many :tours, :through => :tour_dates
  
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  acts_as_rateable
  acts_as_reviewable
  
  has_many :rounds do
    def recent_rounds(max)
      find :all, :limit => max, :order => 'created_at desc'
    end
    
    def by_facebook_uids(facebook_uids, options = {})          
      # some defaults, can override
      find :all, {
          :limit => 5, 
          :order => 'date_played DESC',
          :joins => ' inner join users u on rounds.user_id = u.id',
          :conditions => ['u.facebook_uid in (:uids)', {:uids => facebook_uids}]
          }.merge(options)
    end
    
    def best_rounds_by_facebook_uids(facebook_uids, options = {})
      find :all, {
        :limit => 5,
        :select => 'rounds.id, user_id, score, course_id, date_played, min(score) as "score"',
        :order => 'score asc',
        :joins => ' INNER JOIN users u ON rounds.user_id = u.id',
        :group => 'u.id',
        :conditions => ['u.facebook_uid in (:uids)', {:uids => facebook_uids}]
      }
    end
  
  end
  
  has_many :players, :through => :rounds, :source => :user, :uniq => true 
  
  has_many :wishlists
  has_many :players_want_to_play, :through => :wishlists, :source => :user, :uniq => true
  
  has_many :competitions

  has_and_belongs_to_many :users
  
  # for will_paginate
  cattr_reader :per_page
  @@per_page = 10
        
  def Course.from_kml(kml)
    doc = Hpricot.XML(kml)
    
    course = Course.new
    course.name = (doc/'name').inner_text
    course.description = (doc/'description').inner_text
    course.longitude, course.latitude = (doc/'Point/coordinates').inner_text.chomp.split(',')
    
    course
  end
  
  def calc_geolocations(persist = false)
    places_nearby = Geonames::WebService.find_nearby_place_name(latitude, longitude)
    if persist && places_nearby.length > 0 then
      self.location_text = places_nearby[0].name
      self.save!
    end
    places_nearby
  end
  
  
end
