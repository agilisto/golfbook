include GeoKit::Geocoders
class User < ActiveRecord::Base
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude', :auto_geocode=>{:field=>:address, :error_message=>'Could not geocode address'}
  
  has_many :rounds
  has_many :courses_played, :through => :rounds, :source => :course, :uniq => true
  
  has_and_belongs_to_many :courses
  
  has_many :wishlists
  has_many :courses_want_to_play, :through => :wishlists, :source => :course, :uniq => true do
    def outstanding
      find(:all,
        :joins => ['LEFT OUTER JOIN courses_users on wishlists.course_id = courses_users.course_id'],
        :conditions => ['courses_users.course_id is null'])
    end
 
    def completed
      find(:all,
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
    rounds << round
  end
  
  def has_played(course)
    return if self.courses.include? course
    courses << course
  end
  
  def add_to_wishlist(course)
    return if self.courses_want_to_play.include? course
    courses_want_to_play << course
  end
  
end
