require 'ropencv'
require 'pry'

include OpenCV
include cv

class Matcher
  def initialize(query_image_path)
    @query_image = cv.imread(query_image_path, IMREAD_GRAYSCALE)
    @orb = ORB.create
  end

  def compare_with(target_path)
    @target_image = cv.imread(target_path, IMREAD_GRAYSCALE)
    average < 20
  end

  private

  # computes image features
  def keypoints
    keypoints1 = Vector.new(KeyPoint)
    keypoints2 = Vector.new(KeyPoint)
    @orb.detect(@query_image, keypoints1)
    @orb.detect(@target_image, keypoints2)
    [keypoints1, keypoints2]
  end

  # computes descriptors
  def descriptors
    keypoints1, keypoints2 = keypoints
    descriptors2 = Mat.new(3, 4, CV_64FC1)
    descriptors1 = Mat.new(3, 4, CV_64FC1)
    @orb.compute(@query_image, keypoints1, descriptors1)
    @orb.compute(@target_image, keypoints2, descriptors2)
    [descriptors1, descriptors2]
  end

  def descriptor_matches
    descriptors1, descriptors2 = descriptors
    matcher = BFMatcher.new NORM_HAMMING, true
    matches = Vector.new(DMatch)
    matcher.match(descriptors1, descriptors2, matches)
    matches
  end

  def min_match_distance_of(matches)
    max_dist = 0
    min_dist = 100

    matches.each do |match|
      dist = match.distance
      min_dist = dist if dist < min_dist
      max_dist = dist if dist > max_dist
    end
    # puts "-- Max dist : #{max_dist}"
    # puts "-- Min dist : #{min_dist}"
    min_dist
  end

  def filter(matches)
    good_matches = Vector.new(DMatch)
    min_dist = min_match_distance_of matches
    matches.each do |match|
      good_matches.push_back(match) if match.distance <= 2 * min_dist
    end

    # puts "-- Good matches count: #{good_matches.size}"
    good_matches.sort { |a, b| a.distance <=> b.distance }
  end

  def average
    sum = 0
    good_matches = filter descriptor_matches
    good_matches.each { |match| sum += match.distance }

    avrg = sum.to_f / good_matches.size
    # puts "-- Distance sum: #{sum}"
    puts "-- Average distance: #{avrg}"
    avrg
  end
end

# Matcher.new('007.JPG').compare_with('006.JPG')
# puts '   ----    '
# Matcher.new('008.JPG').compare_with('009.JPG')
# puts '   ----    '
# Matcher.new('006.JPG').compare_with('007.JPG')
# puts '   ----    '
# Matcher.new('006.JPG').compare_with('009.JPG')
