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
  end

  def delete
  end
  
end
