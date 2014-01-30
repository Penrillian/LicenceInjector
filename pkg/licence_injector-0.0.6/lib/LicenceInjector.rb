class LicenceInjector

attr_accessor :licence_file_path, :old_licence_file_path, :src_path, :extensions
attr_reader :changed_files_count

	def initialize(command, licence_file_path, src_path, file_extensions, old_licence_file_path = "", list = false, overwrite = true)
		@licence_file_path = licence_file_path
		@old_licence_file_path = old_licence_file_path
		@src_path = src_path
		@extensions = file_extensions
		@changed_files_count = 0
		@command = command
		@list = list
		@overwrite = overwrite
	end
	
	def read_file file_path
		File.open file_path, "r"  do | file |
			file.read
		end
	end
	
	def inject_licence
		@changed_files_count = 0
		@extensions.each do | extension |
			unless @list
				puts "\tprocessing #{extension} files in #{@src_path}"
				print "\t"
			end
			Dir.glob(@src_path + "/**/*.#{extension}") do |file|	#find src files in current folder and all subfolders
				case  
					when @command == :inject
						inject_licence_into_file file
					when @command == :replace
						replace_old_licence file
				end
			end
			unless @list
				puts
			end
		end
		unless @list
			puts
		end
		unless @list
			if @overwrite
				puts "There were #{@changed_files_count} changes made"
			else
				puts "#{@changed_files_count} file(s) were found. Use the --overwrite flag to make changes to the files"
			end
		end
	end
	
	def replace_old_licence file
		src = read_file file
		
		src_after_replacing_licence = src.gsub(read_file(@old_licence_file_path), read_file(@licence_file_path))

		unless src_after_replacing_licence === src
			if @overwrite
				begin
					output = File.new(file, "w")
					output.write src_after_replacing_licence
					output.close
				rescue
					puts
					STDERR.puts "ERROR: There was a problem writing to '#{file}"
					exit 1
				end
			end
			
			if @list
				puts File.absolute_path(file)
			else
				print "."
			end
			@changed_files_count += 1
		end
		@changed_files_count
	end
	
	def inject_licence_into_file file
		# possible refactor here - using an array to read the src so we can easily check the 
		# first line for special content. If we used a string we could reuse the read file method 
		# but lose the nice array methods... Instinct is to use array
		old_content = []
		newcontent = []
		File.open(file, "r") do | f |
			old_content = f.readlines
		end

		#some files need to have their first lines maintained such as xml files and files using a shebang
		unless old_content.first.nil? # empty file
			if old_content.first.start_with?("#!") || old_content.first.start_with?("<?xml")
				newcontent.push old_content.first
				old_content.shift
			end
		end
		
		newcontent.push read_file @licence_file_path
		newcontent = newcontent + old_content
		
		if @overwrite
			begin
				output = File.new(file, "w")
				newcontent.each { |line| output.write line }
				output.close
			rescue
				puts
				STDERR.puts "ERROR: There was a problem writing to '#{file}"
				exit 1
			end
		end
		
		if @list
			puts File.absolute_path(file)
		else
			print "."
		end
		@changed_files_count += 1
	end
end