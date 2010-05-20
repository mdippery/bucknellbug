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
#import <stdlib.h>


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
       will display 2100 as the update time. The Bucknell weather prof
       believes this is a bug in the way the data file is created, and that
       it's entirely appropriate for me to compensate here. */
    return [[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime] ? @"-0300" : @"-0400";
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

- (BOOL)isAdjacentToToday
{
    int day;
    int today;
    [self getDay:&day today:&today];
    return abs(day - today) <= 1;
}

- (void)getDay:(int *)inDay today:(int *)inToday
{
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date]];
    *inDay = [day day];
    *inToday = [today day];
}

@end
