require 'find'
require 'phashion'
require 'filemagic'
require './matcher.rb'

SUPPORTED_FILETYPES = %(jpeg, jpg, png)

class Recognizer
  def initialize(image_path, directory)
    @matcher = Matcher.new image_path
    @directory = directory
  end

  def files
    Find.find(@directory).select { |e| File.file? e }
  end

  def compare_images
    fm = FileMagic.new
    similiar_images = []

    files.each do |path|
      filetype = fm.file(path).split.first.downcase

      if SUPPORTED_FILETYPES.include? filetype
        similiar_images.push(path) if @matcher.compare_with path
      end
    end
    similiar_images
  end
end
