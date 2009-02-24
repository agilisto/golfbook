class CaddiesController < ApplicationController

  before_filter :set_users

  def index
    @caddies = Caddy.paginate(:page => params[:page], :order => 'created_at desc')
  end

  def new
    @caddy = Caddy.new
  end

  def create
    @course = Course.find_by_name(params["course_filter"])
    @caddy = Caddy.new(params[:caddy])
    @caddy.course = @course
    if @caddy.save
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  private
  def set_users
    @fbuser = fbuser
    @user = current_user
  end

end
