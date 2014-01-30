require 'spec_helper.rb'

describe LicenceInjector do

	before :all do
		@licence_file = "test_licence.txt"
		@licence_text = "/* Copyright Penrillian\nAll rights reserved */\n"
		@xml_licence_text = "<!-- Copyright Penrillian. All rights reserved -->\n"
		@src_text = ["class HelloWorld", "\n{", "\n\tHelloWorld()", "\n\t{", "\n\t}", "\n}"]
		@xml_text = ["<note>\n", "<to>Tove</to>\n", "<from>Jani</from>\n", "<heading>Reminder</heading>\n", "<body>Don't forget me this weekend!</body>\n", "</note>\n"]
		@shebang = "#! /usr/bin/env ruby\n"
		@xml_declaration = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n"
	end
	
	before :each do
		@licenceInjector = LicenceInjector.new :inject, "some licence file path", "srcPath", ["cpp"], "some old licence path", true
	end
	
	describe "#new" do
		it "returns a new LicenceInjector object" do
			@licenceInjector.should be_an_instance_of LicenceInjector
		end
		
		it "throws an ArgumentError when given less than 3 params" do
			lambda { licenceInj = LicenceInjector.new "licence path", "srcPath" }.should raise_exception ArgumentError
		end
	end
	
	describe "#licence_file_path" do
		it "returns the path to the licence file" do
			@licenceInjector.licence_file_path.should eql "some licence file path"
		end
	end
	
	describe "#src_path" do
		it "returns the path to the src files" do
			@licenceInjector.src_path.should eql "srcPath"
		end
	end
		
	describe "#extension" do
		it "returns the extensions of src files to inject" do
			@licenceInjector.extensions.should eql ["cpp"]
		end
	end

	describe "#read_licence_file" do
		before :each do
			create_fake_licence_file(@licence_file, @licence_text)
		end
		
		after :each do
			remove_fake_licence_file @licence_file
		end
		
		after :all do
			remove_test_src_dir
		end
		
		it "reads the text from the licence file" do
			licence_injector = LicenceInjector.new :inject,$Test_src_dir + @licence_file, "src_path", ["cpp"], "some old licence path", true
			licence_injector.read_file($Test_src_dir + @licence_file).should eql @licence_text
		end
	end
	
	describe "#inject_licence_into_file" do
		before :all do
			create_fake_licence_file(@licence_file, @licence_text)
		end
		
		after :all do
			remove_fake_licence_file @licence_file
			remove_test_src_dir
		end
		
		context "source file is not empty" do
			before :each do
				create_fake_source_files(1, @src_text, ".cpp")
			end
			
			after :each do
				remove_fake_source_files(1, ".cpp")
			end
			
			it "injects the text of the licence file into the source files" do
				licence_injector = LicenceInjector.new :inject, $Test_src_dir + @licence_file, ".", ["cpp"], "some old licence path", true
				licence_injector.inject_licence_into_file($Test_src_dir + "0.cpp").should eql 1
				get_file_content($Test_src_dir + "0.cpp").should eql (@licence_text + @src_text.join)
			end
		end
		
		context "source file is empty" do
			before :each do
				create_fake_source_files(1, [""], ".cpp")
			end
			
			after :each do
				remove_fake_source_files(1, ".cpp")
			end
			
			it "injects the text of the licence file into the source files" do
				licence_injector = LicenceInjector.new :inject, $Test_src_dir + @licence_file, ".", ["cpp"], "some old licence path", true
				licence_injector.inject_licence_into_file($Test_src_dir + "0.cpp").should eql 1
				get_file_content($Test_src_dir + "0.cpp").should eql (@licence_text)
			end
		end
	end

	describe "#inject_licence_into_file" do
		after :all do
			remove_test_src_dir
		end
		it "injects the text of the licence file into the source files below the shebang in the source files" do
			create_fake_licence_file(@licence_file, @licence_text)
			shebang_src = @src_text.dup
			shebang_src.unshift(@shebang)
			create_fake_source_files(1, shebang_src, ".cpp")
			licence_injector = LicenceInjector.new :inject,$Test_src_dir + @licence_file, ".", ["cpp"], "some old licence path", true
			licence_injector.inject_licence_into_file($Test_src_dir + "0.cpp").should eql 1
			get_file_content($Test_src_dir + "0.cpp").should eql (@shebang + @licence_text + @src_text.join)
			remove_fake_licence_file @licence_file
			remove_fake_source_files(1, ".cpp")
		end
		
		it "injects the text of the licence file into the source files below the xml declaration in the source files" do
			create_fake_licence_file(@licence_file, @xml_licence_text)
			xml_src = @xml_text.dup
			xml_src.unshift(@xml_declaration)
			create_fake_source_files(1, xml_src, ".xml")
			licence_injector = LicenceInjector.new :inject,$Test_src_dir + @licence_file, ".", ["xml"], "some old licence path", true
			licence_injector.inject_licence_into_file($Test_src_dir + "0.xml").should eql 1
			get_file_content($Test_src_dir + "0.xml").should eql (@xml_declaration + @xml_licence_text + @xml_text.join)
			remove_fake_licence_file @licence_file
			remove_fake_source_files(1, ".xml")
		end
	end
		
	describe "#inject_licence_into_file" do
		after :all do
			remove_test_src_dir
		end
		context "many src files" do
			it "injects the text of the licence file into multiple source files" do
				number_of_src_files = 15
				create_fake_licence_file(@licence_file, @licence_text)
				create_fake_source_files(number_of_src_files, @src_text, ".cpp")
				
				licence_injector = LicenceInjector.new :inject,$Test_src_dir + @licence_file, ".", ["cpp"], "some old licence path", true
				licence_injector.inject_licence
				licence_injector.changed_files_count.should eql number_of_src_files
				number_of_src_files.times do | x |
					get_file_content($Test_src_dir + x.to_s + ".cpp").should eql (@licence_text + @src_text.join)
				end
				
				remove_fake_licence_file @licence_file
				remove_fake_source_files(number_of_src_files, ".cpp")
			end
		end
		
		context "many extensions" do
			it "injects the text of the licence file into multiple source files of differing extensions" do
				number_of_cpp_files = 5
				number_of_hpp_files = 15
				number_of_java_files = 3
				create_fake_licence_file(@licence_file, @licence_text)
				create_fake_source_files(number_of_cpp_files, @src_text, ".cpp")
				create_fake_source_files(number_of_hpp_files, @src_text, ".hpp")
				create_fake_source_files(number_of_java_files, @src_text, ".java")
				
				licence_injector = LicenceInjector.new :inject,$Test_src_dir + @licence_file, ".", ["cpp", "hpp", "java"], "some old licence path", true
				licence_injector.inject_licence
				licence_injector.changed_files_count.should eql number_of_cpp_files + number_of_hpp_files + number_of_java_files
				number_of_cpp_files.times do | x |
					get_file_content($Test_src_dir + x.to_s + ".cpp").should eql (@licence_text + @src_text.join)
				end
				number_of_hpp_files.times do | x |
					get_file_content($Test_src_dir + x.to_s + ".hpp").should eql (@licence_text + @src_text.join)
				end	
				number_of_java_files.times do | x |
					get_file_content($Test_src_dir + x.to_s + ".java").should eql (@licence_text + @src_text.join)
				end
				
				remove_fake_licence_file @licence_file
				remove_fake_source_files(number_of_cpp_files, ".cpp")
				remove_fake_source_files(number_of_hpp_files, ".hpp")
				remove_fake_source_files(number_of_java_files, ".java")
			end
		end
	end
	
	describe "#inject_licence_into_file" do
		after :all do
			remove_test_src_dir
		end
		
		no_of_files = 10
		src_dir = "../testing"
		before :each do
			create_fake_licence_file(@licence_file, @licence_text)
			create_fake_source_files(no_of_files, @src_text, ".cpp", src_dir)
		end
		
		after :each do
			remove_fake_licence_file @licence_file
			remove_fake_source_files(no_of_files, ".cpp", src_dir)
			Dir.rmdir src_dir
		end
		
		it "injects the text of the licence file into the source files not in current directory" do
			licence_injector = LicenceInjector.new :inject,$Test_src_dir + @licence_file, src_dir, ["cpp"], "some old licence path", true
			licence_injector.inject_licence
			licence_injector.changed_files_count.should eql no_of_files
			no_of_files.times do | x |
				get_file_content(src_dir + "/" + x.to_s + ".cpp").should eql (@licence_text + @src_text.join)
			end
		end
	end

	describe "#replace_old_licence" do
		after :all do
			remove_test_src_dir
		end
		
		before :each do
			@old_licence_file = "./old_licence.txt"
			@old_licence_text = "/* Copyright Penrillian 2012\nNo rights reserved */\n"
			create_fake_licence_file(@licence_file, @licence_text)
			create_fake_licence_file(@old_licence_file, @old_licence_text)
			create_fake_source_files(1, @src_text, ".cpp")
		end
		
		after :each do
			remove_fake_licence_file @licence_file
			remove_fake_licence_file @old_licence_file
			remove_fake_source_files(1, ".cpp")
		end
		
		it "replaces the existing licence with a new licence" do
			licence_injector = LicenceInjector.new :inject, $Test_src_dir + @old_licence_file, ".", ["cpp"], "some old licence path", true
			licence_injector.inject_licence_into_file($Test_src_dir + "0.cpp").should eql 1
			get_file_content($Test_src_dir + "0.cpp").should eql (@old_licence_text + @src_text.join)
			
			new_licence_injector = LicenceInjector.new :replace,$Test_src_dir + @licence_file, ".", ["cpp"], $Test_src_dir + @old_licence_file, true
			new_licence_injector.changed_files_count.should eql 0
			new_licence_injector.replace_old_licence($Test_src_dir + "0.cpp").should eql 1
			new_licence_injector.changed_files_count.should eql 1
			get_file_content($Test_src_dir + "0.cpp").should eql (@licence_text + @src_text.join)
		end
	end

	describe "#inject_licence" do
		after :all do
			remove_test_src_dir
		end
		
		before :all do
			@old_licence_file = "./old_licence.txt"
			create_fake_licence_file(@licence_file, "")
			create_fake_licence_file(@old_licence_file, "")
			create_fake_source_files(1, @src_text, ".cpp")
		end
		
		after :all do
			remove_fake_licence_file @licence_file
			remove_fake_licence_file @old_licence_file
			remove_fake_source_files(1, ".cpp")
		end
		
		it "call replace_old_licence when the command is :replace" do
			licence_injector = LicenceInjector.new :replace, $Test_src_dir + @licence_file, ".", ["cpp"], $Test_src_dir + @old_licence_file, true
			
			licence_injector.should_receive(:replace_old_licence).with($Test_src_dir + "0.cpp").once
			licence_injector.inject_licence
		end
				
		it "call inject_licence_into_file when the command is :inject" do
			licence_injector = LicenceInjector.new :inject, $Test_src_dir + @licence_file, ".", ["cpp"], "some old licence path", true
			
			licence_injector.should_receive(:inject_licence_into_file).with($Test_src_dir + "0.cpp").once
			licence_injector.inject_licence
		end
	end

	describe "#inject_licence_into_file" do
		after :all do
			remove_test_src_dir
		end
		
		before :all do
			create_fake_licence_file(@licence_file, @licence_text)
		end
		
		after :all do
			remove_fake_licence_file @licence_file
		end
		
		context "source file is not empty" do
			before :each do
				create_fake_source_files(1, @src_text, ".cpp")
			end
			
			after :each do
				remove_fake_source_files(1, ".cpp")
			end
			
			it "does not change file if --overwrite flag is not passed" do
				licence_injector = LicenceInjector.new :inject, $Test_src_dir + @licence_file, ".", ["cpp"], "some old licence path", true, false
				get_file_content($Test_src_dir + "0.cpp").should eql @src_text.join
			end
		end
	end
	
	describe "#changed file count not incremented when no change has occurred" do
		after :all do
			remove_test_src_dir
		end
		
		before :each do
			@old_licence_file = "./old_licence.txt"
			@old_licence_text = "/* Copyright Penrillian 2012\nNo rights reserved */\n"
			create_fake_licence_file(@licence_file, @licence_text)
			create_fake_licence_file(@old_licence_file, @old_licence_text)
			create_fake_source_files(1, @src_text, ".cpp")
		end
		
		after :each do
			remove_fake_licence_file @licence_file
			remove_fake_licence_file @old_licence_file
			remove_fake_source_files(1, ".cpp")
		end
		
		it "does not increment changed files count when old licence does not exist in source file" do
			new_licence_injector = LicenceInjector.new :replace,$Test_src_dir + @licence_file, ".", ["cpp"], $Test_src_dir + @old_licence_file, true
			new_licence_injector.changed_files_count.should eql 0
			new_licence_injector.replace_old_licence($Test_src_dir + "0.cpp").should eql 0
			new_licence_injector.changed_files_count.should eql 0
			get_file_content($Test_src_dir + "0.cpp").should eql (@src_text.join)
		end
	end
		
	describe "#all occurrences of text is changed, not just the first occurrence" do
		after :all do
			remove_test_src_dir
		end
		
		before :each do
			@old_licence_file = "./old_licence.txt"
			@old_licence_text = "/* Copyright Penrillian 2012\nNo rights reserved */\n"
			create_fake_licence_file(@licence_file, @licence_text)
			create_fake_licence_file(@old_licence_file, @old_licence_text)
			create_fake_source_files(1, @src_text, ".cpp")
		end
		
		after :each do
			remove_fake_licence_file @licence_file
			remove_fake_licence_file @old_licence_file
			remove_fake_source_files(1, ".cpp")
		end
		
		it "does not increment changed files count when old licence does not exist in source file" do
		
			licence_injector = LicenceInjector.new :inject, $Test_src_dir + @old_licence_file, ".", ["cpp"], "some old licence path", true
			licence_injector.inject_licence_into_file($Test_src_dir + "0.cpp").should eql 1
			licence_injector.inject_licence_into_file($Test_src_dir + "0.cpp").should eql 2
			get_file_content($Test_src_dir + "0.cpp").should eql (@old_licence_text + @old_licence_text + @src_text.join)
			
			new_licence_injector = LicenceInjector.new :replace,$Test_src_dir + @licence_file, ".", ["cpp"], $Test_src_dir + @old_licence_file, true
			new_licence_injector.changed_files_count.should eql 0
			new_licence_injector.replace_old_licence($Test_src_dir + "0.cpp").should eql 1
			new_licence_injector.changed_files_count.should eql 1
			get_file_content($Test_src_dir + "0.cpp").should eql (@licence_text + @licence_text + @src_text.join)
		end
	end
end