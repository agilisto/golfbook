class ClubhouseController < ApplicationController
  def index
    sidebar :course_main
    @posts = Review.paginate(:page => params[:page], :order => 'reviews.created_at desc', :include => [:user])
  end
end
