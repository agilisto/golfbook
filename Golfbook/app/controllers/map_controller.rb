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
    @map = GMap.new("map")
    @map.add_map_type_init(:G_PHYSICAL_MAP)
    @map.set_map_type_init(:G_SATELLITE_MAP)
    define_icons
    @map.control_init(:small_zoom => true,:map_type => true)
    @map.center_zoom_init([@course.latitude, @course.longitude], @zoom)
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
  
    #@map.event_init @map, :click, js
    
    #    clusterer = Clusterer.new(markers, :max_visible_markers => 10, :max_lines_per_info_box => 5,
    #      :icon => @lots_icon)

    @map.add_markers(markers)
    
    #@map.overlay_init(clusterer)   
  end
  
  def shownew
    @user = current_user
    @map = GMap.new("map")
    define_icons
    @map.control_init(:small_zoom => true,:map_type => true)
    @map.center_zoom_init([params[:lat], params[:lng]], @zoom)
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
    
    @map = GMap.new("new_course_map_div")   #@size
    define_icons
    @map.control_init(:large_map => true, :map_type => true)
    @map.center_zoom_init([@latitude, @longitude], @zoom)
    js = "function(overlay, latlng)
    {
      if ( overlay != null ) return; 
      var html = '<div class=info_window><a target=_top href=#{url_for_canvas(url_for(:controller=>:courses,:action=>:new,:only_path=>true))}/?lat=' + latlng.lat() + '&lng=' + latlng.lng() + '>Add a course here</a></div>'
      map.openInfoWindow(latlng, html)
    }"
    @map.event_init @map, "click", js
  end
  
  def event_map
    # get user for centering map
    begin
      @user = User.find params[:id]
      @user ||= User.random_user
    rescue
      @user = User.random_user
    end
    
    # create map and define icons
    @map = GMap.new("map")
    @map.control_init(:small_zoom => true)
    @map.center_zoom_init([@user.latitude, @user.longitude], 1)
    define_event_icons
    
    # get recent rounds
    recent_rounds = Round.find(:all, :order => 'rounds.created_at desc', :limit => 20)
    
    # get recent ratings
    recent_ratings = Rating.find(:all, :order => "ratings.created_at desc", :limit => 20)
    
    # get all user info from facebook
    uids = []
    recent_rounds.each { |round| uids << round.user.facebook_uid }
    recent_ratings.each { |rating| uids << rating.user.facebook_uid }
    uids.uniq!
    
    # get player info from FB
    players_xml = fbsession.users_getInfo(:uids => uids, :fields => ["first_name","last_name"])
    players = players_xml.user_list
    
    # build our marker list
    markers = []
    recent_rounds.each do |round|
      player = nil
      players.each do |p|
        player = p if round.user.facebook_uid == p.uid.to_i
      end
      unless player.nil?
        info_window = render_to_string :partial => 'shared/round_info_window', :locals => { :round => round, :player => player }
        marker = GMarker.new([round.course.latitude, round.course.longitude], 
          :title => round.course.name, 
          :icon => @icon_tee,
          :info_window => info_window
        )
        markers << marker
      end
    end
    
    recent_ratings.each do |rating|
      player = nil
      players.each do |p|
        player = p if rating.user.facebook_uid == p.uid.to_i
      end
      info_window = render_to_string :partial => 'shared/rating_info_window', :locals => { :rating => rating, :player => player }
      marker = GMarker.new([rating.rateable.latitude, rating.rateable.longitude], 
        :title => rating.rateable.name, 
        :icon => @icon_pointy,
        :info_window => info_window
      )
      markers << marker
    end
    
    # cluster the markers
    #clusterer = Clusterer.new(markers, :max_visible_markers => 5, :icon => @lots_icon)
    @map.add_markers(markers)
    #@map.overlay_init(clusterer)
    
    render :layout => "map"
  end
  
  def near_user

    @user = User.find(params[:id])
    if @user.nil? 
      @user = User.random_user
    end
    
    @courses = Course.find(:all, :within => DEFAULT_RADIUS, :origin => @user, :limit => DEFAULT_LIMIT)
    
    @map = GMap.new("map")
    @map.control_init(:small_zoom => true,:map_type => true)
    @map.center_zoom_init([@user.latitude, @user.longitude], @zoom)

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

  def at_location
    @user = current_user
    latitude = params["latitude"]
    longitude = params["longitude"]
    @courses = Course.find :all, :origin => [latitude,longitude], :within => DEFAULT_RADIUS
    @map = GMap.new("map")
    @map.control_init(:small_zoom => true,:map_type => true)
    @map.center_zoom_init([latitude, longitude], @zoom)

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
        :icon_anchor => GPoint.new( 10,10 ), 
        :info_window_anchor => GPoint.new( 10,10 )), "icon_tee")
    @map.icon_global_init(GIcon.new( :image => url_for(:controller => :images, :action => 'pointy.gif'),
        :icon_size => GSize.new(23,20), 
        :icon_anchor => GPoint.new(12,10), 
        :info_window_anchor => GPoint.new(12,10)),"icon_pointy")
    @icon_tee = Variable.new("icon_tee")
    @icon_pointy = Variable.new('icon_pointy')
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
    @map_height = params[:height].blank? ? 300 : params[:height].to_i
    @map_width = params[:width].blank? ? 390 : params[:width].to_i
  end
  
  def map_zoom
    @zoom = params[:zoom].blank? ? DEFAULT_ZOOM : params[:zoom].to_i
  end

  def rescue_action(exception)
    puts "=================="
    puts exception.message
    puts exception.backtrace.join("\n")
    puts "=================="
    throw exception
  end

end
