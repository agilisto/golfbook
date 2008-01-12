class ImporterController < ApplicationController

  skip_before_filter :require_facebook_login, :adjust_format_for_facebook
  
  def import
  end

  def process_import
      flash[:notice] = params[:kml][:uploaded_file].class
      redirect_to :action => :import
  end
end
