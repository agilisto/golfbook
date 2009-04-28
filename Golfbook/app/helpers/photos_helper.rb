module PhotosHelper

  def photo_activity_description_of_objects(photo)
    users = photo.users
    rounds = photo.rounds
    courses = photo.courses
    response = []
    unless users.blank?
      response << pluralize(users.size, "user")
    end
    unless rounds.blank?
      response << pluralize(rounds.size, "round")
    end
    unless courses.blank?
      response << pluralize(courses.size, "course")
    end
    #some person identified <here we add the response/>
    if response.size == 1
      response.to_s.sub("1 ","a ")
    else
      response[0..-2].join(", ").gsub("1 ","a ") + " and " + 
        response.last.to_s.sub("1 ","a ")
    end

  end

end
