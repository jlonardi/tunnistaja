require 'shoes'

Shoes.app do
  button("Select query image") do
    @filename = ask_open_file
    puts @filename
  end
  button("Search directory") do
    @folder = ask_open_folder
    puts @folder
  end
end
