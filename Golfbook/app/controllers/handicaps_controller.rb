class HandicapsController < ApplicationController

  def index
    @fbuser = fbuser
    @user = current_user

  end
  
end
