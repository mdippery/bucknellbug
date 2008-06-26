/*
 * BugHUDTextField.m
 * Copyright (c) 2007 Michael Dippery <mdippery@bucknell.edu>
 *
 * All rights reserved. This file is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike license, v2.5. You may use this file so
 * long as you follow the guidelines in the license. You may obtain a copy of the
 * license at
 *
 *     http://creativecommons.org/licenses/by-nc-sa/2.5/legalcode
 */

#import "BugHUDTextField.h"
#import "BugHUDTextFieldCell.h"


@implementation BugHUDTextField

+ (Class)cellClass
{
	return [BugHUDTextFieldCell class];
}

- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	
	// Initialize
	[self setTextColor:[NSColor colorWithDeviceRed:0.78 green:0.78 blue:0.78 alpha:1.0]];
	
	return self;
}

- (void)setTextColor:(NSColor *)color
{
	[[self cell] setTextColor:color];
}

@end
