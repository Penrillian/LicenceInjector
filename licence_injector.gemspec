$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'licence_injector_version.rb'

Gem::Specification.new do |s|
	s.name			= "licence_injector"
	s.version		= Licence_Injector::VERSION
	s.authors		= ["Barry Drinkwater"]
	s.email			= ["barry@penrillian.com"]
	s.homepage		= "http://www.penrillian.com"
	s.summary		= %q{Injects licence text into source files}
	s.description	= %q{licence_injector injects text from the given licence file into each source file found at the given source path whose extension is one of those in the given list of extensions. licence_injector also allows a previously injected licence to be replaced with a new licence}
	s.files			= ["lib/LicenceInjector.rb", "lib/licence_injector_version.rb"]
	s.executables	= ["licence_injector"]
	s.license		= "BSD Clause 2"
	
	s.add_development_dependency("rspec","~> 2.14.1")
	s.add_development_dependency("rdoc","~> 4.0.1")
	s.add_development_dependency("rake","~> 10.1.0")
end