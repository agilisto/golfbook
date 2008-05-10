class MapController < ApplicationController

  DEFAULT_ZOOM = 8
  DEFAULT_ZOOM_COURSE_ONLY = 10
  
  DEFAULT_RADIUS = 20
  DEFAULT_LIMIT = 25
  #skip_before_filter :require_facebook_login, :adjust_format_for_facebook
  before_filter :map_size, :map_zoom

  def show
    @user = current_user
    @course = Course.find(params[:id])
    
    @map = GMap.new(@size)
    @map.add_map_type_init(:G_PHYSICAL_MAP)
    @map.set_map_type_init(:G_SATELLITE_MAP)
    
    define_icons
    
    large_map = ((@size == 'large') || (@size == 'medium')) ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    logger.info "ZOOM : #{@zoom.to_i}"
    @map.center_zoom_init([@course.latitude, @course.longitude],@zoom.to_i)
    #@map.event_init(@map,:moveend,"function(){alert('HOYOYO');}")
    

    info_window = render_to_string :partial => 'shared/info_window', :object => @course
    
    js = "function(overlay, latlng)
    {
      if ( overlay != null ) return; 
      var html = '<div class=info_window><a target=_top href=#{url_for_canvas(url_for(:controller=>:courses,:action=>:new,:only_path=>true))}/?lat=' + latlng.lat() + '&lng=' + latlng.lng() + '>Add A New Course Here</a></div>'
      map.openInfoWindow(latlng, html)
    }"
    
    @courses_near = Course.find(:all, :within => DEFAULT_RADIUS, :origin => @course, :limit => DEFAULT_LIMIT)
    
    markers = []

    
    @courses_near.each do |c|
      @course = c
      info_window = render_to_string :partial => 'shared/info_window', :object => c

      marker = GMarker.new([c.latitude, c.longitude],   
        :title => c.name, :icon => @icon_flag, :info_window => info_window)

      markers.push(marker)
    end
    
    marker = GMarker.new([@course.latitude, @course.longitude],   
      :title => @course.name, :info_window => info_window, :icon => @icon_flag)
    markers.push(marker)
  
    @map.event_init @map, :click, js
    
    clusterer = Clusterer.new(markers, :max_visible_markers => 10, :max_lines_per_info_box => 5,
      :icon => @lots_icon)
    
    @map.overlay_init(clusterer)   
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
  
  def newmap
    @user = current_user
    
    if params.include? 'location'
      RAILS_DEFAULT_LOGGER.debug "Looking up location.."
      # Try GeoKit First
      res=MultiGeocoder.geocode(params['location'])
      if res.success
        @latitude, @longitude = res.lat, res.lng 
      else
        # Fall back to Geonames
        criteria = Geonames::ToponymSearchCriteria.new
        criteria.name_starts_with = params['location']
        criteria.max_rows = '1'

        results = Geonames::WebService.search(criteria).toponyms

        if results.length < 1 
          @latitude, @longitude = @user.latitude, @user.longitude
        else
          @latitude, @longitude = results[0].latitude, results[0].longitude
        end
      end
    else
      RAILS_DEFAULT_LOGGER.debug "No location found, using user home location.."
      @latitude, @longitude = @user.latitude, @user.longitude
    end
    
    @map = GMap.new(@size)
    define_icons
    @map.control_init(:large_map => true, :map_type => true)
    @map.center_zoom_init([@latitude, @longitude], @zoom.to_i)
    js = "function(overlay, latlng)
    {
      if ( overlay != null ) return; 
      var html = '<div class=info_window><a target=_top href=#{url_for_canvas(url_for(:controller=>:courses,:action=>:new,:only_path=>true))}/?lat=' + latlng.lat() + '&lng=' + latlng.lng() + '>Add a course here</a></div>'
      map.openInfoWindow(latlng, html)
    }"
    @map.event_init @map, "click", js
  end
  
  def event_map
    @user = User.find params[:id]
    @user ||= User.random_user
    @map = GMap.new("map")
    @map.control_init(:large_map => false,:map_type => false)
    @map.center_zoom_init([@user.latitude, @user.longitude], @zoom.to_i)
    define_event_icons
    markers = []
    recent_rounds = Round.find(:all, :order => 'rounds.created_at desc', :limit => 20, :include => [:course, :user])
    recent_rounds.each do |round|
      markers << GMarker.new([round.course.latitude, round.course.longitude], :title => round.course.name, :icon => @icon_tee)
    end
    @map.add_markers(markers)
    @map.center_zoom_init([@user.latitude, @user.longitude], 2)
  end
  
  def near_user

    @user = User.find(params[:id])
    if @user.nil? 
      @user = User.random_user
    end
    
    @courses = Course.find(:all, :within => DEFAULT_RADIUS, :origin => @user, :limit => DEFAULT_LIMIT)
    
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
      if ( overlay != null ) return; 
      var html = '<div class=info_window><a target=_top href=#{url_for_canvas(url_for(:controller=>:courses,:action=>:new,:only_path=>true))}/?lat=' + latlng.lat() + '&lng=' + latlng.lng() + '>Add a course here</a></div>'
      map.openInfoWindow(latlng, html)
    }"
    @map.event_init @map, "click", js
    
    @map.overlay_init clusterer
  end

  def at_location
    @user = current_user
    latitude = params["latitude"]
    longitude = params["longitude"]
    @courses = Course.find :all, :origin => [latitude,longitude], :within => DEFAULT_RADIUS
    @map = GMap.new(@size)
    large_map = ((@size == 'large') || (@size == 'medium')) ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    @map.center_zoom_init([latitude, longitude], @zoom.to_i)

    define_icons
    
    markers = []
    
    @courses.each do |c|
      @course = c
      info_window = render_to_string :partial => 'shared/info_window', :object => c 
      marker = GMarker.new([c.latitude, c.longitude],   
        :title => c.name, :icon => @icon_flag, :info_window => info_window)
      markers.push(marker)
    end  
    
    clusterer = Clusterer.new(markers, :max_visible_markers => 10, :max_lines_per_info_box => 5,
      :icon => @lots_icon)
    
    js = "function(overlay, latlng)
    {
      if ( overlay != null ) return; 
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
  def define_event_icons
    @map.icon_global_init( GIcon.new( :image => url_for(:controller => :images, :action => 'tee.gif'), 
        :icon_size => GSize.new( 20,21 ), 
        :icon_anchor => GPoint.new( 25,21 ), 
        :info_window_anchor => GPoint.new( 25,21 )), "icon_tee")
    @icon_tee = Variable.new("icon_tee")
  end
  
  def define_icons
    # # Define the start and end icons  
    @map.icon_global_init( GIcon.new( :image => url_for(:controller => :images, :action => 'red_flag_hole_icon.png'), 
        :icon_size => GSize.new( 50,43 ), 
        :icon_anchor => GPoint.new(25,21), 
        :info_window_anchor => GPoint.new(25,21)),"icon_flag")
        
    @map.icon_global_init( GIcon.new( :image => url_for(:controller => :images, :action => 'blue_flag_hole.png'), 
        :icon_size => GSize.new( 50,43 ), 
        :icon_anchor => GPoint.new(25,21), 
        :info_window_anchor => GPoint.new(25,21)),"blue_icon_flag")
    #:icon_shadow => url_for(:controller => :images, :action => 'shadow-red_flag_hole_icon.png'),
    #:shadow_size => new GSize(72.0, 43.0)), 
    
    @map.icon_global_init(GIcon.new( :image => url_for(:controller => :images, :action => 'lots.png'),
        :icon_size => GSize.new(90,90), 
        :icon_anchor => GPoint.new(45,45), 
        :info_window_anchor => GPoint.new(50,45)),"lots")
    
    @icon_flag = Variable.new("icon_flag")
    @lots_icon = Variable.new('lots')
    @blue_icon_flag = Variable.new('blue_icon_flag')
    
  end
  def map_size
    @size = params[:size] ? params[:size] : 'large'
  end
  
  def map_zoom
    @zoom = params[:zoom] ? params[:zoom] : DEFAULT_ZOOM
  end
  
end
