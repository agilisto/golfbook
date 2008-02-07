class RatingController < ApplicationController

  def rate
    @course = Course.find(params[:id])
    Rating.delete_all(["rateable_type = 'Course' AND rateable_id = ? AND user_id = ?", 
      @course.id, current_user.id])
    @course.add_rating Rating.new(:rating => params[:rating], 
      :user_id => current_user.id)
  end

end