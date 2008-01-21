class HomeController < ApplicationController
  
  NEAR_USER = 'near_user'

  def index
    @fbuser = fbuser
    @user = current_user
    @id = @user.id
    @action = NEAR_USER
    @recent_rounds = Round.find(:all, :order => 'created_at desc', :limit => 3)
  end
  
end
