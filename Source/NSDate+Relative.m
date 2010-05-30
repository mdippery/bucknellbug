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

#import "NSDate+Relative.h"
#import <stdlib.h>

#define SECONDS_IN_A_DAY    (60 * 60 * 24)
#define sgn(x)              (x < 0.0 ? -1 : 1);

@implementation NSDate (RelativeAdditions)

- (int)dayOfMonth
{
    return [[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self] day];
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
    return [self dayOfMonth] == [[NSDate date] dayOfMonth];
}

- (BOOL)isTomorrowOrLater
{
    return [self dayOfMonth] > [[NSDate date] dayOfMonth];
}

- (BOOL)isYesterdayOrEarlier
{
    return [self dayOfMonth] < [[NSDate date] dayOfMonth];
}

- (int)numberOfDaysSinceNow
{
    NSTimeInterval interval = [self timeIntervalSinceNow] / SECONDS_IN_A_DAY;
    int sign = sgn(interval);
    interval = floor(abs(interval));    // If interval is negative, round towards 0, since 6.5 days ago is 6 days ago, not 7
    return (int) (interval * sign);
}

@end
