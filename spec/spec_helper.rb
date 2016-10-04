require_relative '../lib/LicenceInjector.rb'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$Test_src_dir = "./temp_test_files/"
	
def create_fake_licence_file licence_file_name, licence_text = []
	unless Dir.exists? $Test_src_dir 
	#	puts "making directory: #{src_path}"
		Dir.mkdir $Test_src_dir
	end
	File.open $Test_src_dir + licence_file_name, "w"  do | file |
		file.write licence_text
	end
end
	
def remove_fake_licence_file licence_file_name
	FileUtils.remove_file $Test_src_dir + licence_file_name
end

def remove_test_src_dir
	if Dir.exists? $Test_src_dir
		Dir.rmdir $Test_src_dir
	end
end

def create_fake_source_files no_of_files, src_text, extension, src_path = $Test_src_dir
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

def remove_fake_source_files no_of_files, extension, src_path = $Test_src_dir
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