# BucknellBug Rakefile
# Copyright (C) 2006-2010 Michael Dippery <mdippery@gmail.com>
#
# This Makefile is free software; the author gives unlimited permission
# to copy and/or distribute it, with or without modifications,
# as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

NAME    = 'BucknellBug'
PROJECT = 'BucknellBug.xcodeproj'
TARGET  = {:bin => 'BucknellBug', :dmg => 'Disk Image', :sparkle => 'Sparkle Archive'}
CONFIG  = {:release => 'Release', :debug => 'Debug'}

def xcodebuild(project, target, configuration)
  system "xcodebuild", "-project", project, "-target", target, "-configuration", configuration, "build"
end

def xcodeclean(project, configuration)
  system "xcodebuild", "-project", project, "-alltargets", "-configuration", configuration, "clean"
end

def agvtool
  system "agvtool", "next-version", "-all"
end

def ruby(*args)
  system "ruby", *args
end

desc "Builds a release version"
task :default => :release

desc "Cleans built products"
task :clean do
  CONFIG.each_value { |config| xcodeclean PROJECT, config }
end

desc "Builds a release version"
task :release do
  xcodebuild PROJECT, TARGET[:bin], CONFIG[:release]
end

desc "Builds a debug version"
task :debug do
  xcodebuild PROJECT, TARGET[:bin], CONFIG[:debug]
end

desc "Packages a release version into a distributable .dmg"
task :dist do
  xcodebuild PROJECT, TARGET[:dmg], CONFIG[:release]
end

desc "Creates a Sparkle archive"
task :sparkle do
  xcodebuild PROJECT, TARGET[:sparkle], CONFIG[:release]
end

desc "Signs the Sparkle archive"
task :sign_sparkle => [:sparkle] do
  ruby "Tools/sign_update.rb", "build/Release/#{NAME}.tgz", "#{ENV['HOME']}/.sparkle/BucknellBug/dsa_priv.pem"
end

desc "Increments the version number by one"
task :bump_version do
  agvtool
end
