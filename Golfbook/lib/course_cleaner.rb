class CourseCleaner
  
  REGEX = /^[0-9 \t\?\/Ã]+/
  
  def self.clean
    
    courses = Course.find(:all)
    courses.each do |course|
      if course.name =~ REGEX
        puts "#{course.name}" if course.name =~ REGEX
        puts "\t#{course.name.gsub(REGEX, '')}" if course.name =~ REGEX
        course.name.gsub!(REGEX, '')
        course.save!
      end
    end
    true
  end
end