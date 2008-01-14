class MapController < ApplicationController

  DEFAULT_ZOOM = 8
  DEFAULT_RADIUS = 50
  #skip_before_filter :require_facebook_login, :adjust_format_for_facebook
  before_filter :map_size, :map_zoom

  def show   
    @course = Course.find(params[:id])
    @map = GMap.new(@size)
    
    define_icons
    
    large_map = ((@size == 'large') || (@size == 'medium')) ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    @map.center_zoom_init([@course.latitude, @course.longitude],@zoom.to_i)

    info_window = render_to_string :partial => 'shared/info_window', :object => @course
  
    marker = GMarker.new([@course.latitude, @course.longitude],   
       :title => @course.name, :info_window => info_window, :icon => @icon_flag)  
     @map.overlay_init(marker)    
  end
  
  def near_user
    begin
    @user = User.find(params[:id])
    if @user.nil? 
      @user = User.random_user
    end
    
    @courses = Course.find(:all, :within => DEFAULT_RADIUS, :origin => @user)
    
    @map = GMap.new(@size)
    large_map = ((@size == 'large') || (@size == 'medium')) ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    @map.center_zoom_init([@user.latitude, @user.longitude], @zoom.to_i)

    define_icons
    
    @courses.each do |c|
      info_window = render_to_string :partial => 'shared/info_window', :object => c
      marker = GMarker.new([c.latitude, c.longitude],   
         :title => c.name, :info_window => info_window, :icon => @icon_flag)
      @map.overlay_init(marker)    
    end  
    rescue StandardError => e
      puts "=================="
      puts "ERROR #{e.inspect}"
      puts e.backtrace.join('\n')
      puts "=================="
    end  
  end

  # rfacebook breaks this outside of the canvas, hence this method so i 
  # can see what is going on
  def rescue_action(exception)
      puts "=================="
      puts exception.message
      puts exception.backtrace.join("\n")
      puts "=================="
      throw exception
  end
  
  private
  def define_icons
    # # Define the start and end icons  
    @map.icon_global_init( GIcon.new( :image => url_for(:controller => :images, :action => 'red_flag_hole_icon.png'), 
      :icon_size => GSize.new( 50,43 ), 
      :icon_anchor => GPoint.new(25,20), 
      :info_window_anchor => GPoint.new(39,15)),"icon_flag")
      #:icon_shadow => url_for(:controller => :images, :action => 'shadow-red_flag_hole_icon.png'),
      #:shadow_size => new GSize(72.0, 43.0)), 
      
    @icon_flag = Variable.new("icon_flag");
  end
  def map_size
    @size = params[:size] ? params[:size] : 'large'
  end
  
  def map_zoom
    @zoom = params[:zoom] ? params[:zoom] : DEFAULT_ZOOM
  end
  
end
