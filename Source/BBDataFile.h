/*
 * Copyright (c) 2006-2011 Michael Dippery <mdippery@gmail.com>
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

@class CSVFile;


@interface BBDataFile : NSObject
{
    CSVFile *data;
@private
    int timestampOffset;
}
+ (NSURL *)defaultURL;
+ (NSStringEncoding)defaultEncoding;
+ (NSTimeZone *)defaultTimeZone;

- (id)init;

- (BOOL)update;

- (NSDate *)date;
- (double)temperature;
- (double)humidity;
- (unsigned int)pressure;
- (unsigned int)rainfall;
@end
