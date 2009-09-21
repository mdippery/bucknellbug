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

#import "NSDateAdditions.h"


@implementation NSDate (BucknellBugAdditions)

+ (id)dateWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour
{
    return [[[self alloc] initWithYear:year month:month day:day hour:hour] autorelease];
}
- (id)initWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour
{
    NSMutableString *dateStr = [[[NSMutableString alloc] initWithFormat:@"%@-", year] autorelease];
    [dateStr appendFormat:@"%@-%@ ", month, day];
    
    // Apparently the data stream isn't adjusted for Daylight Savings Time, so
    // if it IS Daylight Saving Time, we have to adjust the string manually,
    // as well as set the time zone.
    if ([[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime]) {
        [dateStr appendFormat:@"%d:00:00 ", ([hour intValue] / 100) - 1];
        [dateStr appendString:@"-0400"];
    } else {
        [dateStr appendFormat:@"%d:00:00 ", [hour intValue] / 100];
        [dateStr appendString:@"-0500"];
    }
    
    NSLog(@"Making date with str: %@", dateStr);
    // I think I'm supposed to release the allocated 'self' here in order to
    // return the NEW date object...right?
    [self release];
    self = [[NSDate alloc] initWithString:dateStr];
    return self;
}

@end
