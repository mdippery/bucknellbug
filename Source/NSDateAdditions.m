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


@interface NSDate (PrivateBucknellBugAdditions)
- (void)getDay:(int *)inDay andToday:(int *)inToday;
@end


@implementation NSDate (PrivateBucknellBugAdditions)

- (void)getDay:(int *)inDay andToday:(int *)inToday
{
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date]];
    *inDay = [day day];
    *inToday = [today day];
}

@end


@implementation NSDate (BucknellBugAdditions)

+ (id)dateWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour
{
    return [[[self alloc] initWithYear:year month:month day:day hour:hour] autorelease];
}

- (id)initWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour
{
    BOOL makeYesterday = NO;
    NSMutableString *dateStr = [[[NSMutableString alloc] initWithFormat:@"%@-", year] autorelease];
    [dateStr appendFormat:@"%@-%@ ", month, day];
    
    // Apparently the data stream isn't adjusted for Daylight Savings Time, so
    // if it IS Daylight Saving Time, we have to adjust the string manually,
    // as well as set the time zone.
    if ([[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime]) {
        // But at 11PM EDT (12AM EDT), we have to change the hour to be
        // 11, and the day to be the day BEFORE -- otherwise we get a
        // situation in which the hour is set to -1. That's bad.
        int hourVal = [hour intValue];
        if (hourVal == 0) {
            NSLog(@"Hour val is %d, adjusting to 24", hourVal);
            hourVal = 24 * 100;     // Because we subtract 1 from it, below
            makeYesterday = YES;    // We'll fix this below
        }
        
        [dateStr appendFormat:@"%d:00:00 ", (hourVal / 100) - 1];
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
    // If we had to adjust the date for DST (above) and it was midnight,
    // it's actually 11 PM on the PREVIOUS day, so handle that here.
    if (makeYesterday) {
        // Pretty sure I should autorelease here, too, but I'm not sure
        [self autorelease];
        self = [self addTimeInterval:(24.0 * 60.0 * 60.0)];
    }
    return self;
}

- (BOOL)isToday
{
    int day;
    int today;
    [self getDay:&day andToday:&today];
    return day == today;
}

- (BOOL)isTomorrowOrLater
{
    int day;
    int today;
    [self getDay:&day andToday:&today];
    return day > today;
}

- (BOOL)isYesterdayOrEarlier
{
    int day;
    int today;
    [self getDay:&day andToday:&today];
    return day < today;
}

@end
