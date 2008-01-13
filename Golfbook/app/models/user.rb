class User < ActiveRecord::Base
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude', :auto_geocode=>{:field=>:address, :error_message=>'Could not geocode address'}
  acts_as_facebook_user
    
  def location_set?
    if self.latitude.nil? 
      false
    else
       true
    end
  end
  
end
