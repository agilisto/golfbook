require File.dirname(__FILE__) + '/../test_helper'

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
    
      @gansbaai_description = 'Gansbaai Golf Club &#133; Golf is a passion for so many people in South Africa. The country has many many golf courses and the weather and scenery to match. Find your perfect Golf Course here. By the sea, mountains, desert, game reserve, rivers, or wherever.<br>http://vuvuzela.com/accomodationquickfind/'
  end
  
  def test_parse
    course = Course.from_kml(@gansbaai)
    assert_equal('Gansbaai Golf Club', course.name, 'Course name doesn''t match')
    #assert_equal(@gansbaai_description, course.description, 'Course description doesn''t match')
    assert_in_delta(19.34903, course.latitude, 0.05, 'Course latitude not populated correctly')
    assert_in_delta(-34.61839, course.longitude, 0.05,'Course longitude not populated correctly')
  end
  
  def test_course_save
    gansbaai = courses(:gansbaai)
    assert gansbaai.save
    
    target = Course.find_by_name('Gansbaai Golf Club')
    assert_not_nil(target, 'Gansbaai')
  end
  
end
