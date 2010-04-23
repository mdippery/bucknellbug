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

VERSION      = 2.0a7
PROJECT      = BucknellBug.xcodeproj
TARGET       = BucknellBug
CONFIG       = Release
DEBUG_CONFIG = Debug
DMG_TARGET   = Disk Image
SRC_TGZ      = BucknellBug-$(VERSION).src.tgz

.PHONY: release debug dist src-dist clean

release:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIG) build

debug:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(DEBUG_CONFIG) build

dmg:
	xcodebuild -project $(PROJECT) -target "$(DMG_TARGET)" -configuration $(CONFIG) build

src-dist:
	git archive --format=tar --prefix=bucknellbug/ master | gzip > $(SRC_TGZ)

clean:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIG) clean
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(DEBUG_CONFIG) clean
	xcodebuild -project $(PROJECT) -target "$(DMG_TARGET)" -configuration $(CONFIG) clean
	xcodebuild -project $(PROJECT) -target "$(DMG_TARGET)" -configuration $(DEBUG_CONFIG) clean
	-rm -f $(SRC_TGZ)
