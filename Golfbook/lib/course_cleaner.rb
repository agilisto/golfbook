class CourseCleaner
  
  REGEX = /^[0-9 \t\?\/Ã]+/
  
  def self.clean
    
    courses = Course.find(:all)
    courses.each do |course|
      if course.name =~ REGEX
        puts "#{course.name}"
        puts "\t#{course.name.gsub(REGEX, '')}"
        course.name.gsub!(REGEX, '')
        course.save!
      end
    end
    true
  end
end