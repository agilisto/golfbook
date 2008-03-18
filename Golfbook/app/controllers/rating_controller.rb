class RatingController < ApplicationController
  
  before_filter :set_response_type
  
  def rate
    @course = Course.find(params[:id])
    
    Rating.delete_all(["rateable_type = 'Course' AND rateable_id = ? AND user_id = ?", 
      @course.id, current_user.id])
    
    rating = Rating.new(:rating => params[:rating], 
        :user_id => current_user.id)
        
    @course.add_rating rating
    
    title_template = render_to_string :partial => 'feeds/course_rated_title'
    body_template = render_to_string :partial => 'feeds/course_rated_body'
    
    title_data = {:course_name => @course.name, 
      :course_url => url_for(:controller => :courses, :action => :show, :id => @course.id)}
    body_data = {:course_name => @course.name,
      :course_url => url_for(:controller => :courses, :action => :show, :id => @course.id),
      :rating => rating.rating.to_s, 
      :golfbook_url =>  url_for(:controller => :home, :action => :index)}
      
    image_1 = url_for(:controller => :images, :action => 'tees_50.png', :only_path => false)
    image_1_link = url_for(:controller => :courses, :action => :show, :id => @course.id)
      
    result = fbsession.feed_publishTemplatizedAction(:actor_id => fbsession.session_user_id, 
      :title_template => title_template, :title_data => title_data.to_json, 
      :body_template => body_template, :body_data => body_data.to_json, 
      :image_1 => image_1, :image_1_link => image_1_link)
      
    # logger.debug "Publish Templatized Action Result : #{result}"
  
    render :partial => 'ratings/rate', :locals => { :asset => @course }, :layout => false
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
   def set_response_type
     request.format = :fbml  
   end
  
end