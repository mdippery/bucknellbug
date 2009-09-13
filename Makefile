# Copyright (c) 2006-2007 Michael Dippery <mdippery@bucknell.edu>
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

VERSION      = 2.0a1
PROJECT      = BucknellBug.xcodeproj
TARGET       = BucknellBug
CONFIG       = Release
DEBUG_CONFIG = Debug
TARBALL      = BucknellBug-$(VERSION).tgz
SRCTARBALL   = BucknellBug-$(VERSION).src.tgz

.PHONY: release debug dist src-dist clean

release:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIG) build

debug:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(DEBUG_CONFIG) build

dist: release
	tar czf $(TARBALL) -C build/Release/ BucknellBug.app/

src-dist:
	tar czf $(SRCTARBALL) . --exclude build

clean:
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIG) clean
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(DEBUG_CONFIG) clean
	-rm -f $(TARBALL)
	-rm -f $(SRCTARBALL)
