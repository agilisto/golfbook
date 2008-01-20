class RoundController < ApplicationController

  def new
      @course = Course.find(params[:course_id])
      @round = Round.new
      @round.course = @course
      @user = current_user
  end

  def create
    @user = current_user
    @round = @user.rounds.build(params[:round]) 

    if @round.save
      redirect_to :action => :index
    else
      @course = Course.find(@round.course_id)
      render :action => 'new'
    end
    
  end

  def update
  end

  def index
     @user = current_user
     @rounds = Round.paginate_by_user_id @user.id, :page => params[:page], :order => 'date_played desc' 

     respond_to do |format|
       format.fbml 
       format.xml  { render :xml => @courses }
     end
  end

  def delete
  end
  
end
