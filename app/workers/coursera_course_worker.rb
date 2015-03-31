class CourseraCourseWorker < AbstractCourseWorker

  MOOC_PROVIDER_NAME = 'coursera'
  MOOC_PROVIDER_API_LINK = 'https://api.coursera.org/api/catalog.v1/courses'
  MOOC_PROVIDER_FIELDS = '?fields=language,shortDescription,photo,aboutTheCourse,video,targetAudience,instructor,estimatedClassWorkload,recommendedBackground'
  MOOC_PROVIDER_INCLUDES = '?includes=categories,universities,sessions'
  COURSE_LINK_BODY = 'https://www.coursera.org/course/'

  def mooc_provider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def get_course_data
    response = RestClient.get(MOOC_PROVIDER_API_LINK + MOOC_PROVIDER_FIELDS)
    JSON.parse response
  end

  def handle_response_data response_data

    update_map = create_update_map mooc_provider

    response_data["elements"].each { |course_element|
      course = Course.find_by(:provider_course_id => course_element['id'], :mooc_provider_id => mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      course.name = course_element['name']
      course.provider_course_id = course_element['id']
      course.mooc_provider_id = mooc_provider.id
      course.url = COURSE_LINK_BODY + course_element['shortName']
      course.language = course_element['language']
      course.imageId = course_element['photo']
      course.start_date = DateTime.now
      course.end_date = DateTime.now + 1.month
      course.description = course_element['shortDescription']
      # if !course_element['lecturer'].empty?
      #   course.course_instructors = [course_element['lecturer']]
      # end
      #course.open_for_registration = !course_element['locked']

      course.save
    }
    evaluate_update_map update_map
  end

end
