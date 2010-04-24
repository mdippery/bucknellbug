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
    NSString *tz = [[NSTimeZone timeZoneWithName:@"US/Eastern"] isDaylightSavingTime] ? @"-0400" : @"-0500";
    NSMutableString *dateStr = [[[NSMutableString alloc] initWithFormat:@"%@-%@-%@ %d:00:00 %@", year, month, day, ([hour intValue] / 100), tz] autorelease];
    
    // I think I'm supposed to release the allocated 'self' here in order to
    // return the NEW date object...right?
    [self release];
    self = [[NSDate alloc] initWithString:dateStr];
    return self;
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
