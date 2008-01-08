require 'hpricot'

class Course < ActiveRecord::Base
  
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  
  def Course.from_kml(kml)
    doc = Hpricot.XML(kml)
    
    course = Course.new
    course.name = (doc/'name').inner_text
    course.description = (doc/'description').inner_text
    course.latitude, course.longitude = (doc/'Point/coordinates').inner_text.chomp.split(',')
    
    course
  end
  
end
