# Copyright (c) 2006-2010 Michael Dippery <mdippery@gmail.com>
# BucknellBug Makefile
#
# This Makefile is free software; the author gives unlimited permission
# to copy and/or distribute it, with or without modifications,
# as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

PROJECT        = BucknellBug.xcodeproj
TARGET         = BucknellBug
CONFIG         = Release
DEBUG_CONFIG   = Debug
DMG_TARGET     = Disk Image
SRC_TARGET     = Source Archive
SPARKLE_TARGET = Sparkle Archive

.PHONY: release debug dist src-dist clean

release:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIG) build

debug:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(DEBUG_CONFIG) build

dmg:
	xcodebuild -project $(PROJECT) -target "$(DMG_TARGET)" -configuration $(CONFIG) build

srcdist:
	xcodebuild -project $(PROJECT) -target "$(SRC_TARGET)" -configuration $(CONFIG) build

sparke:
	xcodebuild -project $(PROJECT) -target "$(SPARKLE_TARGET)" -configuration $(CONFIG) build

clean:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIG) clean
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(DEBUG_CONFIG) clean
	xcodebuild -project $(PROJECT) -target "$(DMG_TARGET)" -configuration $(CONFIG) clean
	xcodebuild -project $(PROJECT) -target "$(SRC_TARGET)" -configuration $(CONFIG) clean
	xcodebuild -project $(PROJECT) -target "$(SPARKLE_TARGET)" -configuration $(CONFIG) clean
