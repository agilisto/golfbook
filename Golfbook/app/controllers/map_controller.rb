class MapController < ApplicationController

  DEFAULT_ZOOM = 8
  DEFAULT_RADIUS = 100
  #skip_before_filter :require_facebook_login, :adjust_format_for_facebook
  before_filter :map_size, :map_zoom

  def show   
    @course = Course.find(params[:id])
    @map = GMap.new(@size)
    large_map = @size == 'large' ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    @map.center_zoom_init([@course.latitude, @course.longitude],@zoom.to_i)

    marker = GMarker.new([@course.latitude, @course.longitude],   
       :title => @course.name, :info_window => @course.description)  
     @map.overlay_init(marker)    
  end
  
  def near_user
    begin
    @user = User.find(params[:id])
    @courses = Course.find(:all, :within => DEFAULT_RADIUS, :origin => @user)
    
    @map = GMap.new(@size)
    large_map = @size == 'large' ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    @map.center_zoom_init([@user.latitude, @user.longitude],@zoom.to_i)

    @courses.each do |c|
      marker = GMarker.new([c.latitude, c.longitude],   
         :title => c.name)
      @map.overlay_init(marker)    
    end  
    rescue StandardError => e
      puts "=================="
      puts "ERROR #{e.inspect}"
      puts "=================="
      
    end  
  end

  def rescue_action(exception)
      puts "=================="
      puts exception.message
      puts exception.backtrace.join("\n")
      puts "=================="
    
  end
  
  private
  def map_size
    @size = params[:size] ? params[:size] : 'large'
  end
  
  def map_zoom
    @zoom = params[:zoom] ? params[:zoom] : DEFAULT_ZOOM
  end
  
end
