require 'rubygems'
require 'rmagick'
require 'fox16'
require 'pry'
require './recognizer'

include Fox

class ImageViewer < FXMainWindow
  def initialize(app)
    super(app, "Image Viewer", width: 500, height: 450)

    query_image_frame = FXHorizontalFrame.new(self)

    select_image_button = FXButton.new(self, "Select image")
    select_image_button.connect(SEL_COMMAND) do
      dialog = FXFileDialog.new(self, "Load a File")
      dialog.selectMode = SELECTFILE_EXISTING
      dialog.patternList = ["All Files (*)"]

      # TODO: validate that file is an image
      if dialog.execute != 0
        # Load the query image
        @query_image_path = dialog.filename
        pic = Magick::Image.read(@query_image_path).first

        # Clear previous query image
        query_image_frame.each_child do |child|
          query_image_frame.removeChild(child)
        end

        # TODO: correct size to static width and height
        thumbnail = pic.thumbnail(pic.columns * 0.09, pic.rows * 0.09)

        # Create the thumbnail
        fx_query_thumb = FXJPGImage.new(getApp, thumbnail.to_blob { |attrs| attrs.format = 'JPEG' })
        FXImageFrame.new(query_image_frame, fx_query_thumb).create
        query_image_frame.recalc
      end
    end

    search_button = FXButton.new(self, "Search")
    result_images_frame = FXHorizontalFrame.new(self)
    search_button.connect(SEL_COMMAND) do
      unless @query_image_path.nil?
        results = Recognizer.new(@query_image_path, Dir.pwd).compare_images
        if results.any?
          # Clear results
          result_images_frame.each_child do |child|
            result_images_frame.removeChild(child)
          end
        end
        results.each do |path|
          pic = Magick::Image.read(path).first

          # TODO: correct size to static width and height
          thumbnail = pic.thumbnail(pic.columns * 0.09, pic.rows * 0.09)

          # Create the thumbnail
          fx_result_thumb = FXJPGImage.new(getApp, thumbnail.to_blob { |attrs| attrs.format = 'JPEG' })
          FXImageFrame.new(result_images_frame, fx_result_thumb).create
          result_images_frame.recalc
        end
      end
    end
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

app = FXApp.new
mainwin = ImageViewer.new(app)

app.create
app.run
