class RoundController < ApplicationController
  
  def set_active_submenu
    logger.debug 
    @action = @action_name.intern
  end

  def new
    @course = Course.find(params[:id])
    @round = Round.new(:course => @course)
    @user = current_user
  end

  def create
    @user = current_user
    @round = Round.new(params[:round])
  
    @user.post_score(@round)
    # TODO: Failure

    redirect_to :action => :index
    
  end
  
  def show
    @round = Round.find(params[:id]) 
    @user = @round.user
    @course = @round.course
    @best_round = @user.rounds.best(@course)
    uids = fbsession.friends_get.uid_list
    @friends_recent_rounds = @course.rounds.by_facebook_uids(uids) 
    @friends_best_rounds = @course.rounds.best_rounds_by_facebook_uids(uids)
  end

  def update
  end

  def index
    @user = User.find(:first, :conditions => params[:user_id]) 
    @user = current_user if @user.nil?
    @rounds = Round.paginate_by_user_id @user.id, :page => params[:page], :order => 'date_played desc' 

    respond_to do |format|
      format.fbml 
      format.xml  { render :xml => @courses }
    end
  end

  def delete
  end
  
end
