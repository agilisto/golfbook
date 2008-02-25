require File.dirname(__FILE__) + '/../test_helper'
require 'KmlCourseImporter.rb'
require 'stringio'

class CourseTest < ActiveSupport::TestCase
  
  def setup
      	@gansbaai = <<END_OF_STRING
      	<Placemark>
    			<name>Gansbaai Golf Club</name>
    			<Snippet maxLines="2">
    <![CDATA[Gansbaai Golf Club &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/]]>			</Snippet>
    			<description><![CDATA[Gansbaai Golf Club &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/]]></description>
    			<styleUrl>#gv_waypoint</styleUrl>
    			<Style>
    				<LabelStyle>
    					<color>ffffffff</color>
    				</LabelStyle>
    			</Style>
    			<Point>
    				<coordinates>19.34903,-34.61839,0</coordinates>
    			</Point>
    		</Placemark>
END_OF_STRING

      @full_doc = <<END_OF_DOC
      <?xml version="1.0" encoding="UTF-8"?>
      <kml xmlns="http://earth.google.com/kml/2.1">
      <Document>
      	<name>South African Golf</name>
      	<Snippet maxLines="2">
      <![CDATA[created by <A href="http://www.gpsvisualizer.com/">GPS Visualizer</A>]]>	</Snippet>
      	<Style id="gv_waypoint">
      		<IconStyle>
      			<Icon>
      				<href>http://maps.google.com/mapfiles/kml/pal4/icon57.png</href>
      			</Icon>
      		</IconStyle>
      	</Style>
      	<Folder>
      		<name>Waypoints</name>
      		<Placemark>
      			<name>Gansbaai Golf Club</name>
      			<Snippet maxLines="2">
      <![CDATA[Gansbaai Golf Club &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/]]>			</Snippet>
      			<description><![CDATA[Gansbaai Golf Club &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/]]></description>
      			<styleUrl>#gv_waypoint</styleUrl>
      			<Style>
      				<LabelStyle>
      					<color>ffffffff</color>
      				</LabelStyle>
      			</Style>
      			<Point>
      				<coordinates>19.34903,-34.61839,0</coordinates>
      			</Point>
      		</Placemark>
      		<Placemark><name>Bredasdorp Golf Course</name>
    			<Snippet maxLines="2">
    <![CDATA[Bredasdorp Golf Course &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/]]>			</Snippet>
    			<description><![CDATA[Bredasdorp Golf Course &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/]]></description>
    			<styleUrl>#gv_waypoint</styleUrl>
    			<Style>
    				<LabelStyle>
    					<color>ffffffff</color>
    				</LabelStyle>
    			</Style>
    			<Point>
    				<coordinates>20.04777,-34.5435,0</coordinates>
    			</Point>
    		</Placemark>
    			</Folder>
        </Document>
        </kml>
END_OF_DOC
   
      @gansbaai_description = 'Gansbaai Golf Club &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/'
  end
  
  def test_parse
    course = Course.from_kml(@gansbaai)
    assert_equal('Gansbaai Golf Club', course.name, 'Course name doesn''t match')
    #assert_equal(@gansbaai_description, course.description, 'Course description doesn''t match')
    assert_in_delta(19.34903, course.longitude, 0.05, 'Course latitude not populated correctly')
    assert_in_delta(-34.61839, course.latitude, 0.05,'Course longitude not populated correctly')
  end
  
  def test_course_save
    gansbaai = courses(:gansbaai)
    assert gansbaai.save
    
    target = Course.find_by_name('Gansbaai Golf Club')
    assert_not_nil(target, 'Gansbaai')
  end
  
  def test_full_document_parse
    expected = Array.new
    expected.push('Gansbaai Golf Club')
    expected.push('Bredasdorp Golf Course')
    
    doc_stream = StringIO.new(@full_doc)
    
    KmlCourseImporter.process_kml(doc_stream) do |course_kml|
      course = Course.from_kml(course_kml)
      assert_equal(expected.shift, course.name)
    end
    
  end
  
  def test_location_text_population
    gansbaai = courses(:gansbaai)
    locations = gansbaai.calc_geolocations(true)
    p(locations[0].name)
    assert_not_nil(gansbaai.location_text)
    assert_equal('Kleinbaai', gansbaai.location_text)
  end
  
  def test_recent_rounds_by_facebook_friends
    gansbaai = courses(:gansbaai)
    rounds = gansbaai.rounds.by_facebook_uids([12345, 12346])
    assert_equal(3, rounds.length)
    
    pebble = courses(:pebble_beach)

    rounds = pebble.rounds.by_facebook_uids([12345, 12346])
    assert_equal(0, rounds.length)
    
    arnold = users(:arnold_palmer)
    round = Round.new(:score => 61, :course => pebble)
    arnold.post_score(round)
    
    rounds = pebble.rounds.by_facebook_uids([12345, 12346])
    assert_equal(0, rounds.length)
    
    rounds = pebble.rounds.by_facebook_uids([12345, 12348])
    assert_equal(1, rounds.length)
  end

  def test_best_rounds_by_facebook_friends
    gansbaai = courses(:gansbaai)
    rounds = gansbaai.rounds.best_rounds_by_facebook_uids([12345, 12346])
    assert_equal(2, rounds.length)
    assert_equal(69, rounds[0].score)
    assert_equal(70, rounds[1].score)
  end
  
  def test_rate_course
    
  end
  
end
