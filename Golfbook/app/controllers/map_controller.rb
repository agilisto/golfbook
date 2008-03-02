class MapController < ApplicationController

  DEFAULT_ZOOM = 8
  DEFAULT_RADIUS = 50
  #skip_before_filter :require_facebook_login, :adjust_format_for_facebook
  before_filter :map_size, :map_zoom

  def show
    @user = current_user
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
  
  def shownew
    @user = current_user
    @map = GMap.new(@size)
    
    define_icons
    
    large_map = ((@size == 'large') || (@size == 'medium')) ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    @map.center_zoom_init([params[:lat], params[:lng]],@zoom.to_i)

    marker = GMarker.new([params[:lat], params[:lng]],   
      :title => 'New Course', :icon => @icon_flag)  
    @map.overlay_init(marker)    
  end
  
  def near_user

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
    
    markers = []
    
    @courses.each do |c|
      @course = c
      info_window = render_to_string :partial => 'shared/info_window', :object => c

      #      tabs = []
      #      t1 = GInfoWindowTab.new
      #      t1.tab = 'Info'
      #      t1.content = info_window
      #      tabs << t1
      #      
      #      t2 = GInfoWindowTab.new
      #      t2.tab = 'Location'
      #      tabs << t2
      #             
      marker = GMarker.new([c.latitude, c.longitude],   
        :title => c.name, :icon => @icon_flag, :info_window => info_window)

      markers.push(marker)
    end  
    
    clusterer = Clusterer.new(markers, :max_visible_markers => 10, :max_lines_per_info_box => 5,
      :icon => @lots_icon)
    
    js = "function(overlay, latlng)
    {
      var html = '<div class=info_window><a target=_top href=#{url_for_canvas(url_for(:controller=>:courses,:action=>:new,:only_path=>true))}/?lat=' + latlng.lat() + '&lng=' + latlng.lng() + '>Add a course here</a></div>'
      map.openInfoWindow(latlng, html)
    }"
    
    @map.event_init @map, "click", js
    
    @map.overlay_init clusterer
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
        :icon_anchor => GPoint.new(25,21), 
        :info_window_anchor => GPoint.new(25,21)),"icon_flag")
    #:icon_shadow => url_for(:controller => :images, :action => 'shadow-red_flag_hole_icon.png'),
    #:shadow_size => new GSize(72.0, 43.0)), 
    
    @map.icon_global_init(GIcon.new( :image => url_for(:controller => :images, :action => 'lots.png'),
        :icon_size => GSize.new(90,90), 
        :icon_anchor => GPoint.new(45,45), 
        :info_window_anchor => GPoint.new(50,45)),"lots")
    
    @icon_flag = Variable.new("icon_flag");
    @lots_icon = Variable.new('lots')
  end
  def map_size
    @size = params[:size] ? params[:size] : 'large'
  end
  
  def map_zoom
    @zoom = params[:zoom] ? params[:zoom] : DEFAULT_ZOOM
  end
  
end
