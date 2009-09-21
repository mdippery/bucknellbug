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
    int realHour = [hour intValue] / 100;
    BOOL isDST = [[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime];
    NSString *dstOffset = isDST ? @"-0400" : @"-0500";
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %d:00:00 %@", year, month, day, realHour, dstOffset];
    NSLog(@"Making date with str: %@", dateStr);
    // I think I'm supposed to release the allocated 'self' here in order to
    // return the NEW date object...right?
    [self release];
    self = [[NSDate alloc] initWithString:dateStr];
    return self;
}

@end
