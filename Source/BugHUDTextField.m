/*
 * Copyright (c) 2006-2009 Michael Dippery <mdippery@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
