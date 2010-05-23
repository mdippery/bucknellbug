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

#define SECONDS_IN_A_DAY    (60 * 60 * 24)
#define sgn(x)              (x < 0.0 ? -1 : 1);

@interface NSDate (PrivateBucknellBugAdditions)
- (void)getDay:(int *)inDay today:(int *)inToday;
@end

@implementation NSDate (BucknellBugAdditions)

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

- (int)numberOfDaysSinceNow
{
    NSTimeInterval interval = [self timeIntervalSinceNow] / SECONDS_IN_A_DAY;
    int sign = sgn(interval);
    interval = floor(abs(interval));    // If interval is negative, round towards 0, since 6.5 days ago is 6 days ago, not 7
    return (int) (interval * sign);
}

- (void)getDay:(int *)inDay today:(int *)inToday
{
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date]];
    *inDay = [day day];
    *inToday = [today day];
}

@end
