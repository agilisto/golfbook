class ReviewsController < ApplicationController
  
  def new  
  end
  
  def create
    @course = Course.find(params[:id])
    @review = Review.new(params[:review])
    @review.user_id = current_user.id
    @course.add_review @review
    
    title_template = render_to_string :partial => 'feeds/course_reviewed_title'
    body_template = render_to_string :partial => 'feeds/course_reviewed_body'
    
    title_data = {:course_name => @course.name, 
      :course_url => url_for(:controller => :courses, :action => :show, :id => @course.id)}
    body_data = {:course_name => @course.name,
      :course_url => url_for(:controller => :courses, :action => :show, :id => @course.id),
      :review_url => url_for(:controller => :reviews, :action => :show, :id => @review.id),
      :review => @review.review }
      
    image_1 = url_for(:controller => :images, :action => 'ball_50.png', :only_path => false)
    image_1_link = url_for(:controller => :courses, :action => :show, :id => @course.id)
      
    result = fbsession.feed_publishTemplatizedAction(:actor_id => fbsession.session_user_id, 
      :title_template => title_template, :title_data => title_data.to_json, 
      :body_template => body_template, :body_data => body_data.to_json, 
      :image_1 => image_1, :image_1_link => image_1_link)
      
    flash[:notice] = "Your review has been added to the course"
    redirect_to :controller => :courses, :action => :show, :id => @course.id
  end
  
  def show
    @review = Review.find(params[:id])
  end
  
end
