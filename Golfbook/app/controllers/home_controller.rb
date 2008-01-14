class HomeController < ApplicationController
  
  NEAR_USER = 'near_user'

  def index
    @fbuser = fbuser
    @user = user
    @id = @user.id
    @action = NEAR_USER
  end
  
end
