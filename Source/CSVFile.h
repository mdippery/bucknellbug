/*
 * Copyright (c) 2006-2011 Michael Dippery <michael@monkey-robot.com>
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

#import <Cocoa/Cocoa.h>


@interface CSVFile : NSObject
{
    NSArray *data;
}

- (id)initWithContentsOfString:(NSString *)s;
- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc;
- (NSString *)objectAtIndex:(unsigned int)i;
- (NSUInteger)count;

@end
