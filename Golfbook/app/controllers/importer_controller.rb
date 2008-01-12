require 'KmlCourseImporter.rb'

class ImporterController < ApplicationController

  skip_before_filter :require_facebook_login, :adjust_format_for_facebook
  
  def import
  end

  def process_import
      
      file_for_import = params[:kml][:uploaded_file]
      courses = Array.new
      
      Course.transaction do
        KmlCourseImporter.process_kml(file_for_import) do |course_kml|
          course = Course.from_kml(course_kml)
          courses.push course
          course.save!
        end
      
        flash[:notice] = "Imported #{courses.length} courses"
        redirect_to :controller => :Importer, :action => :import
      
      end
  end
end
