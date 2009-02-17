require 'hpricot'
require 'geonames'

class Course < ActiveRecord::Base
  
  belongs_to :added_by, :class_name => "User", :foreign_key => "added_by_id"
  
  has_many :tours, :through => :tour_dates
  
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  acts_as_rateable
  acts_as_reviewable
  
  def self.recently_played(facebook_uids = [], num = 6)
    conditions = facebook_uids.blank? ? nil : ["users.facebook_uid IN (?)",facebook_uids]
    find(:all,
      :limit => num,
      :select => 'users.id as user_id, users.facebook_uid as facebook_uid, courses.id as course_id, courses.name as course_name',
      :order => 'courses_users.created_at desc',
      :joins => [:users],
      :conditions => conditions
      )
  end

  def self.recently_played_with_rounds(num = 4)
    find(:all, :include => :last_four_rounds, :order => 'rounds.created_at desc', :limit => num)
  end

  def self.recently_played_by_friends(facebook_uids = [], num = 6)
    conditions = facebook_uids.blank? ? nil : ["users.facebook_uid IN (?)",facebook_uids]
    find(:all,
      :limit => num,
#      :select => 'users.id as user_id, users.facebook_uid as facebook_uid, courses.id as course_id, courses.name as course_name',
      :order => 'courses_users.created_at desc',
      :joins => [:users],
      :conditions => conditions
      )
  end

  def self.recently_reviewed(num)   #Ivor: This should actually use a sql distinct call
    recent_reviews = Review.find(:all, :conditions => "reviewable_type = 'Course'", :order => 'created_at desc', :limit => num*2)
    recent_courses = recent_reviews.collect{|x|x.reviewable}.compact.uniq
    unless (difs = (num - recent_courses.size)) > 0
      recent_courses[0..(num - 1)]
    else
      extra_reviews = Review.find(:all, :order => 'created_at desc', :limit => num*2, :conditions => ["reviewable_type = 'Course' AND reviewable_id NOT IN (?)",recent_courses.collect{|x|x.id}])
      recent_courses + extra_reviews.collect{|x|x.reviewable}.compact.uniq[0..difs - 1]
    end
  end

  def self.recently_rated(num)
    recent_ratings = Rating.find(:all, :conditions => "rateable_type = 'Course'", :order => 'created_at desc', :limit => num*2)
    recent_courses = recent_ratings.collect{|x|x.rateable}.compact.uniq
    unless (difs = (num - recent_courses.size)) > 0
      recent_courses[0..(num - 1)]
    else
      extra_reviews = Rating.find(:all, :order => 'created_at desc', :limit => num*2, :conditions => ["rateable_type = 'Course' AND rateable_id NOT IN (?)",recent_courses.collect{|x|x.id}])
      recent_courses + extra_reviews.collect{|x|x.reviewable}.compact.uniq[0..difs - 1]
    end
  end

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
    
    def leaderboard
      find :all, {
        :limit => 10,
        :select => 'rounds.id, user_id, score, course_id, date_played, min(score) as "score"',
        :order => 'score asc',
        :joins => ' INNER JOIN users u ON rounds.user_id = u.id',
        :group => 'u.id'
      }
    end
  
  end

  has_many :last_four_rounds, :class_name => "Round", :order => 'rounds.date_played desc', :limit => 4
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
  
  def self.recent_additions(options = {})
    limits = {:order => 'created_at desc', :limit => 10}
    recent_courses = Course.find(:all, limits.merge(options))
  end

  def course_rating
    read_attribute(:course_rating) || 71  #defaults course_rating to 71 - instruction from Dean
  end
  
  
end
