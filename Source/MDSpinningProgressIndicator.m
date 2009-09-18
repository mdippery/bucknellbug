/*
 * Copyright (c) 2009 Michael Dippery <mdippery@gmail.com>
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

#import "MDSpinningProgressIndicator.h"


@implementation MDSpinningProgressIndicator

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setHidden:YES];
        [self setDrawBackground:NO];
        [self setForegroundColor:[NSColor whiteColor]];
    }
    return self;
}

- (void)startAnimation:(id)sender
{
    [self setHidden:NO];
    [super startAnimation:sender];
}

- (void)stopAnimation:(id)sender
{
    [self setHidden:YES];
    [super startAnimation:sender];
}

@end
