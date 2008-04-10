include GeoKit::Geocoders
class User < ActiveRecord::Base
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  
  # home course
  belongs_to :home_course, :class_name => "Course"
  
  has_many :games do
    def for_course course
      find :all, 
        :conditions => ['course_id = :course_id and date_to_play > :date', 
        { :course_id => course.id, :date => Date.today }],
        :order => "date_to_play asc",
        :limit => 3
    end
    def upcoming
      find :all,
        :order => 'date_to_play asc',
        :limit => 3
    end
  end
  
  has_many :game_players
  has_many :games_to_play, :through => :game_players, :source => :game, :uniq => true do
    def for_course course
      find :all, 
        :conditions => ['course_id = :course_id and date_to_play > :date', 
        { :course_id => course.id, :date => Date.today }],
        :order => "date_to_play asc",
        :limit => 3
    end
    def upcoming
      find :all,
        :order => "date_to_play asc",
        :limit => 3
    end
  end
  
  has_many :rounds do
    def recent max
      find :all, :order => 'date_played desc', :limit => max
    end
    def best(course)
      find :first,
        :conditions => ['course_id = :id', {:id => course.id}],
        :limit => 1,
        :order => 'score asc'
    end
  end
  
  has_many :courses_played, :through => :rounds, :source => :course, :uniq => true
  
  has_and_belongs_to_many :courses
  
  has_many :tours do
    def upcoming
      find :all,
        :joins => 'inner join tour_dates on tours.id = tour_dates.tour_id',
        :conditions => ['tour_dates.to_play_at >= :today', {:today => Date.today}],
        :order => 'tour_dates.to_play_at asc'
    end
  end
  
  has_many :competitions do
    def upcoming
      find :all,
        :order => "start_date asc",
        :conditions => ["start_date <= :today and end_date >= :today", {:today => Date.today}]
    end
  end
  
  has_many :competitors
  has_many :competition_entries, :through => :competitors, :source => :competition do
    def upcoming
      find :all,
        :order => "start_date asc",
        :conditions => ["start_date <= :today and end_date >= :today", {:today => Date.today}]
    end
  end
  
  has_many :tour_players
  has_many :tour_entries, :through => :tour_players, :source => :tour do
    def upcoming
      find :all,
        :joins => 'inner join tour_dates on tours.id = tour_dates.tour_id',
        :conditions => ['tour_dates.to_play_at >= :today', {:today => Date.today}],
        :order => 'tour_dates.to_play_at asc'
    end
  end
  
  has_many :wishlists
  has_many :courses_want_to_play, :through => :wishlists, :source => :course, :uniq => true, :order => 'target_date desc' do
        
    def outstanding
      find(:all,
        :include => [:rounds],
        :joins => ['LEFT OUTER JOIN courses_users on wishlists.course_id = courses_users.course_id'],
        :conditions => ['courses_users.course_id is null'])
    end
 
    def completed
      find(:all,
        :include => [:rounds],
        :joins => ['INNER JOIN courses_users on wishlists.course_id = courses_users.course_id'])
    end
  end
    
  def location_set?
    if self.latitude.nil? 
      false
    else
      true
    end
  end
  
  def geocode
    begin
      # Try GeoKit First
      res=MultiGeocoder.geocode(self.address)
      puts res.inspect
      if res.success
        self.latitude, self.longitude = res.lat, res.lng 
        self.address = res.full_address
      else

        # Fall back to Geonames
        criteria = Geonames::ToponymSearchCriteria.new
        criteria.name_starts_with = self.address
        criteria.max_rows = '1'

        results = Geonames::WebService.search(criteria).toponyms

        if results.length < 1 
          return false
        else
          self.latitude, self.longitude = results[0].latitude, results[0].longitude
          self.address = results[0].name << ', ' << results[0].country_name
          return true
        end
      end
    rescue StandardError => e
      puts e.inspect
      false
    end
  end
  
  def self.random_user
    count = User.count
    return User.find(:first, :order => 'id', :offset => rand(count))
  end

  def post_score(round)
    has_played(round.course)
    self.rounds << round
  end
  
  def has_played_course?(course)
    if self.courses.include? course
      true
    else
      false
    end
  end
  
  def has_played(course)
    return if self.courses.include? course
    self.courses << course
  end
  
  def add_to_wishlist(course)
    return if self.courses_want_to_play.include?(course)
    self.courses_want_to_play << course
  end
  
end
