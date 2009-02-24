class WishlistController < ApplicationController

  def new
    @course = Course.find(params[:id])

    if current_user.add_to_wishlist(@course)
      flash[:notice] = "#{@course.name} added to your list of courses to play."
    else
      flash[:notice] = "You've already marked '#{@course.name} as a course you'd like to play."
    end
    redirect_to course_add_wishlist_target_date_url(:id => @course.id, :only_path => true)
  end
  
  def set_target_date
    @wishlist = current_user.wishlists.find_by_course_id(params[:id])
    @course = @wishlist.course
  end

  def update_target_date
    @wishlist = Wishlist.find(params[:id])
    
    respond_to do |format|
      if @wishlist.update_attributes(params[:wishlist])
        flash[:notice] = "#{@wishlist.course.name} target date set"
        format.fbml { redirect_to :action => 'index' }
        format.xml  { render :xml => @wishlist, :status => :created, :location => @wishlist }
      else
        format.fbml { render :action => "new" }
        format.xml  { render :xml => @wishlist.errors, :status => :unprocessable_entity }
      end
    end
  end

  def index
    @user = current_user
    @courses = @user.courses_want_to_play
  end
  
  def set_active_submenu
    @action = :wishlist
  end
    
end
