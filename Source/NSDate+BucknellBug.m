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

#import "NSDate+BucknellBug.h"


@interface NSDate (PrivateBucknellBugAdditions)
- (NSString *)timeZone;
- (void)getDay:(int *)inDay today:(int *)inToday;
@end

@implementation NSDate (BucknellBugAdditions)

+ (id)dateWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour
{
    return [[[self alloc] initWithYear:year month:month day:day hour:hour] autorelease];
}

- (id)initWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour
{
    NSString *tz = [self timeZone];
    NSMutableString *dateStr = [[[NSMutableString alloc] initWithFormat:@"%@-%@-%@ %d:00:00 %@", year, month, day, ([hour intValue] / 100), tz] autorelease];
    
    // I think I'm supposed to release the allocated 'self' here in order to
    // return the NEW date object...right?
    [self autorelease];
    self = [[NSDate alloc] initWithString:dateStr];
    return self;
}

- (NSString *)timeZone
{
    /* For some reason, the weather feed shows the time in the future. For
       example, if it's 8:02 PM and the weather feed was just updated, it
       will display 2100 as the update time. Maybe this is semantically
       correct for some reason, I don't know (I should talk to Bucknell's
       weather guy to find out), but it's confusing to the user to see a
       last updated time in the _future_. This chunk of code will adjust
       the last updated time to make more sense, until I can figure out
       what's going on. */
#if ADJUST_WEATHER_FEED
#warning Adjusting for error in weather feed in -[NSDate timeZone]
    return [[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime] ? @"-0300" : @"-0400";
#else
    return [[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime] ? @"-0400" : @"-0500";
#endif
}

- (BOOL)isAfter:(NSDate *)date
{
    return [self compare:date] == NSOrderedDescending;
}

- (BOOL)isBefore:(NSDate *)date
{
    return [self compare:date] == NSOrderedAscending;
}

- (BOOL)isToday
{
    int day;
    int today;
    [self getDay:&day today:&today];
    return day == today;
}

- (BOOL)isTomorrowOrLater
{
    int day;
    int today;
    [self getDay:&day today:&today];
    return day > today;
}

- (BOOL)isYesterdayOrEarlier
{
    int day;
    int today;
    [self getDay:&day today:&today];
    return day < today;
}

- (void)getDay:(int *)inDay today:(int *)inToday
{
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date]];
    *inDay = [day day];
    *inToday = [today day];
}

@end
