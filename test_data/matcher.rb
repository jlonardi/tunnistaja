require 'ropencv'
require 'pry'

include OpenCV
include cv

img1 = cv.imread('008.JPG', IMREAD_GRAYSCALE)
img2 = cv.imread('009.JPG', IMREAD_GRAYSCALE)

if img1.empty || img2.empty
  puts("Can't read one of the images\n")
  return -1
end

if img1.empty || img2.empty
  puts("Can't read one of the images\n")
  return -1
end

orb = ORB.create

keypoints1 = Vector.new(KeyPoint)
keypoints2 = Vector.new(KeyPoint)
orb.detect(img1, keypoints1)
orb.detect(img2, keypoints2)

# computing descriptors
descriptors2 = Mat.new(3, 4, CV_64FC1)
descriptors1 = Mat.new(3, 4, CV_64FC1)
orb.compute(img1, keypoints1, descriptors1)
orb.compute(img2, keypoints2, descriptors2)

# matching descriptors
matcher = BFMatcher.new NORM_HAMMING, true
matches = Vector.new(DMatch)
matcher.match(descriptors1, descriptors2, matches)

max_dist = 0
min_dist = 100

matches.each do |match|
  dist = match.distance
  min_dist = dist if dist < min_dist
  max_dist = dist if dist > max_dist
end

puts "-- Max dist : #{max_dist}"
puts "-- Min dist : #{min_dist}"

good_matches = Vector.new(DMatch)
matches.each do |match|
  good_matches.push_back(match) if match.distance <= 4 * min_dist
end

good_matches.sort { |a, b| a.distance <=> b.distance }

sum = 0
good_matches.each { |match| sum += match.distance }

average = sum.to_f / good_matches.size

puts "-- Distance sum : #{sum}"
puts "-- Matches: #{matches.size}"
puts "-- Good matches: #{good_matches.size}"
puts "-- Average distance: #{average}"

# drawing the results
# img_matches = Mat.new(3, 4, CV_64FC1)
# cv.draw_matches(img1, keypoints1, img2, keypoints2, good_matches, img_matches)
# cv.imshow("matches", img_matches)
# cv.waitKey(0)
