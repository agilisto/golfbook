include GeoKit::Geocoders
class User < ActiveRecord::Base
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude', :auto_geocode=>{:field=>:address, :error_message=>'Could not geocode address'}
    
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
end
