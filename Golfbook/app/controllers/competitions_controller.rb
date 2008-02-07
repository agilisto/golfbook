class CompetitionsController < ApplicationController
  def index
    @user = current_user
    @competitions = Competition.paginate @user.competitions, :page => params[:page], :order => :name
    @action = :competitions
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @competitions }
    end
  end
end
