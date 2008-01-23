class HomeController < ApplicationController
  
  NEAR_ME = 'near_user'

  def index
    @fbuser = fbuser
    @user = current_user
    @id = @user.id
    @action = NEAR_ME
    @recent_rounds = Round.find(:all, :order => 'created_at desc', :limit => 3)
  end
  
end
