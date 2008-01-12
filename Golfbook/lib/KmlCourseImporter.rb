require 'rubygems'
require 'hpricot'

class KmlCourseImporter

  def KmlCourseImporter.process_kml(kml_doc)
    doc = Hpricot.XML(kml_doc)
    (doc/:Document/:Folder/:Placemark).each do |placemark|
      yield placemark.inner_html
    end
  end
  
end  