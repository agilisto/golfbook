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
    if @round.course.nil? && params[:course_id]
      @round.course_id = Course.find(params[:course_id]).id
    end
  
    logger.info "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
    logger.info "\n\n\n\n"
    logger.info "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"


    @user.post_score(@round)
    # TODO: Failure

    logger.info "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
    logger.info "\n\n\n\n"
    logger.info "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"


    publish_round_posted_action(@round.id)

    logger.info "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
    logger.info "\n\n\n\n"
    logger.info "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"

    update_profile_box(@user.id)

    logger.info "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
    logger.info "\n\n\n\n"
    logger.info "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
    
    redirect_to :action => :index, :user_id => @user.id
    
  end
  
  def show
    @round = Round.find(params[:id]) 
    @user = @round.user
    @course = @round.course
    @best_round = @user.rounds.best(@course)
    uids = fbsession.friends_get.uid_list
    @friends_recent_rounds = @course.rounds.by_facebook_uids(uids) 
    @friends_best_rounds = @course.rounds.best_rounds_by_facebook_uids(uids)
    sidebar :course_specific
  end

  def update
  end

  def index
    @user = User.find(params[:user_id])
    @user = current_user if @user.nil?
    @rounds = Round.paginate_by_user_id @user.id, :page => params[:page], :order => 'date_played desc' 

    respond_to do |format|
      format.fbml 
      format.xml  { render :xml => @courses }
    end
  end

  def destroy
    @round = Round.find(params[:id])
    @round.destroy
    flash[:notice] = 'Your round has been deleted.'
    redirect_to :action => :index, :user_id => @round.user.id
  end
  

  private
  def rescue_action(exception)
    puts "=================="
    puts exception.message
    puts exception.backtrace.join("\n")
    puts "=================="
    throw exception
  end



end
