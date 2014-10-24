#!/usr/bin/perl -w

# This bumps release build numbers by 1, and debug build numbers by .1.

use strict;

my $debugConfig   = "Debug";
my $releaseConfig = "Release";
my $infoFile      = "Resources/Info.plist";
my $buildNum      = 0;

# More info on Xcode environment variables can be found here:
# http://maxao.free.fr/xcode-plugin-interface/build-settings.html#variables
if ($ENV{CONFIGURATION} == $debugConfig) {
	# Debug config: Increment by .1
	$buildNum = .1;
} elsif ($ENV{CONFIGURATION} == $releaseConfig) {
	# Release config: Increment by 1
	$buildNum = 1;
}

# Open the file and get the contents
open(FH, "$infoFile") or die "$0: $infoFile: $!\n";
my $content = join("", <FH>);

# Find <CFBundleVersion> and increment current value
if ($content =~ m/(\s+<key>CFBundleVersion<\/key>\s+<string>)(\d+)(<\/string>)/) {
	$buildNum += $2;
	if ($ENV{CONFIGURATION} == $releaseConfig) {
		$buildNum = int($buildNum);   # Round down to integer if release build
	}
	$content =~ s/(\s+<key>CFBundleVersion<\/key>\s+<string>)(\d+)(<\/string>)/$1$buildNum$3/;
}

# Write out the new contents
open(FH, ">$infoFile") or die "$0: $infoFile: $!\n";
print FH $content;
close(FH);
