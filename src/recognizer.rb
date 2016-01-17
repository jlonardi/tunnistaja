require 'find'

class Recognizer

  def initialize(image, directory)
    @image = image;
    @directory = directory
  end

  def files
    Find.find(@directory).select {|e| File.file? e }
  end

  def load_images
    files.each do |path|
      puts path
    end
  end
end

