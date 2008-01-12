class MapController < ApplicationController

  DEFAULT_ZOOM = 8
  
  #skip_before_filter :require_facebook_login, :adjust_format_for_facebook
  before_filter :map_size, :map_zoom

  def show
    
    @course = Course.find(params[:id])
    @map = GMap.new(@size)
    large_map = @size == 'large' ? true : false
    @map.control_init(:large_map => large_map,:map_type => true)
    @map.center_zoom_init([@course.longitude, @course.latitude],@zoom.to_i)
    marker = GMarker.new([@course.longitude, @course.latitude],   
       :title => @course.name, :info_window => @course.description)  
     @map.overlay_init(marker)
    
  end

  private
  def map_size
    @size = params[:size] ? params[:size] : 'large'
  end
  
  def map_zoom
    @zoom = params[:zoom] ? params[:zoom] : DEFAULT_ZOOM
  end
  
end
