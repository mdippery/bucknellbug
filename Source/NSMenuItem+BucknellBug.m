/*
 * Copyright (c) 2006-2010 Michael Dippery <mdippery@gmail.com>
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

#import "NSMenuItem+BucknellBug.h"


@implementation NSMenuItem (BucknellBugAdditions)

- (void)updateTitle:(NSString *)aTitle
{
    NSRange colon = [[self title] rangeOfString:@": "];
    NSString *baseTitle = [[self title] substringToIndex:(colon.location + 2)];
    NSString *newTitle = [baseTitle stringByAppendingString:aTitle];
    [self setTitle:newTitle];
}

@end
