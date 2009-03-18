require "fileutils"
require "erb"

def create_file(dest_filename, str)
  FileUtils.rm_rf(dest_filename)
  File.open(dest_filename, "w") do |f|
    f << str
  end
end

def from_template(dest_filename, template_filename)
  str = File.open(template_filename).read
  erb = ERB.new(str)
  create_file(dest_filename, erb.result(binding))
end
