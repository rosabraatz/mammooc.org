# -*- encoding : utf-8 -*-
require 'aws-sdk'
require 'singleton'

class AmazonS3
  include Singleton

  BUCKET_NAME = 'mammooc'

  def initialize
    new_aws_resource
  end

  def get_object(key)
    @bucket.object(key)
  end

  def get_data(key)
    @bucket.object(key).get.body.read
  end

  def provider_logos_hash_for_courses(courses)
    logos = {}
    courses.each do |course|
      unless logos.key?(course.mooc_provider.logo_id)
        logos[course.mooc_provider.logo_id] = get_url(course.mooc_provider.logo_id)
      end
    end

    logos
  end

  def get_url(key)
    @bucket.object(key).presigned_url 'GET'
  end

  def all_provider_logos_hash
    logos = {}
    MoocProvider.find_each do |provider|
      logos[provider.logo_id] = get_url(provider.logo_id)
    end

    logos
  end

  def provider_logos_hash_for_recommendations(recommendations)
    logos = {}
    recommendations.each do |recommendation|
      unless logos.key?(recommendation.course.mooc_provider.logo_id)
        logos[recommendation.course.mooc_provider.logo_id] = get_url(recommendation.course.mooc_provider.logo_id)
      end
    end

    logos
  end

  def author_profile_images_hash_for_recommendations(recommendations)
    author_images = {}
    recommendations.each do |recommendation|
      unless author_images.key?(recommendation.author.profile_image_id)
        author_images[recommendation.author.profile_image_id] = get_url(recommendation.author.profile_image_id)
      end
    end

    author_images
  end

  def user_profile_images_hash_for_users(users, images = {})
    users.each do |user|
      unless images.key?(user.profile_image_id)
        images[user.profile_image_id] = get_url(user.profile_image_id)
      end
    end
    images
  end

  def group_images_hash_for_groups(groups, images = {})
    groups.each do |group|
      unless images.key?(group.image_id)
        images[group.image_id] = get_url(group.image_id)
      end
    end
    images
  end

  def put_data(key, file, options_hash = {})
    object = get_object(key)

    unless options_hash.key?(:cache_control_time_in_seconds)
      options_hash[:cache_control_time_in_seconds] = 15.days
    end

    object.put(body: file, content_encoding: options_hash[:content_encoding], content_type: options_hash[:content_type], cache_control: "max-age=#{options_hash[:cache_control_time_in_seconds]}", storage_class: 'REDUCED_REDUNDANCY')
  end

  private

  def new_aws_resource
    s3 = Aws::S3::Resource.new
    @bucket = s3.bucket(BUCKET_NAME)
  end
end