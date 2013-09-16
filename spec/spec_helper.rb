require_relative '..\lib\LicenceInjector.rb'

	
def create_fake_licence_file licence_file_name, licence_text = []
	licence_file = File.open licence_file_name, "w"  do | file |
		file.write licence_text
	end
end
	
def remove_fake_licence_file licence_file_name
	FileUtils.remove_file licence_file_name
end

def create_fake_source_files no_of_files, src_text, extension, src_path = "."
	unless Dir.exists? src_path 
	#	puts "making directory: #{src_path}"
		Dir.mkdir src_path
	end
	#puts
	#print "Creating files"
	no_of_files.times do | i |
	#	print "."
		file = File.open (src_path + "/" + i.to_s + extension), "w" do | file |
			src_text.each do | line |
				file.write line
			end
		end
	end
	#puts
end

def remove_fake_source_files no_of_files, extension, src_path = "."
	#puts
	#print "Deleting files"
	no_of_files.times do | i |
	#	print "."
		FileUtils.remove_file src_path + "/" + i.to_s + extension
	end
	#puts
end

def get_file_content file
	File.open file do | open_file |
		open_file.read
	end
end