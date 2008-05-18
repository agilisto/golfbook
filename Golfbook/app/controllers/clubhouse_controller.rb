class ClubhouseController < ApplicationController
  def index
    @posts = Review.paginate(:page => params[:page], :order => 'reviews.created_at desc', :include => [:user])
  end
end
