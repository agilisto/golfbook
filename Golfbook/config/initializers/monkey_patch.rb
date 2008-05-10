module Ym4r
  module GmPlugin 
    class GMap
      
      def add_markers(markers)
        markers.each { |marker| @init << add_overlay(marker) }
      end
      
    end
  end
end