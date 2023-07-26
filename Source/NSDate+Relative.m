/*
 * Copyright (c) 2006-2023 Michael Dippery <michael@monkey-robot.com>
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

@interface NSCalendar (DefaultCalendar)
+ (id)defaultCalendar;
@end

@implementation NSCalendar (DefaultCalendar)

+ (id)defaultCalendar
{
    return [[[self alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease];
}

@end

@implementation NSDate (RelativeAdditions)

- (NSInteger)dayOfMonth
{
    return [[[NSCalendar defaultCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (BOOL)isAfter:(NSDate *)date
{
    return [self compare:date] == NSOrderedDescending;
}

- (BOOL)isBefore:(NSDate *)date
{
    return [self compare:date] == NSOrderedAscending;
}

- (NSDate *)dateAtMidnight
{
    return [[NSCalendar defaultCalendar] dateFromComponents:[[NSCalendar defaultCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self]];
}

- (BOOL)isToday
{
    return [[self dateAtMidnight] isEqualToDate:[[NSDate date] dateAtMidnight]];
}

- (BOOL)isTomorrowOrLater
{
    return [[self dateAtMidnight] isAfter:[[NSDate date] dateAtMidnight]];
}

- (BOOL)isYesterdayOrEarlier
{
    return [[self dateAtMidnight] isBefore:[[NSDate date] dateAtMidnight]];
}

- (BOOL)isMoreThan:(unsigned int)daysAgo;
{
    NSTimeInterval interval = [self timeIntervalSinceDate:[NSDate date]];
    interval = -interval;    // Dates in the past return negative intervals
    NSTimeInterval days = interval / SECONDS_IN_A_DAY;
    return days > (double) daysAgo;
}

- (int)daysSinceToday
{
    return (int) ([[self dateAtMidnight] timeIntervalSinceDate:[[NSDate date] dateAtMidnight]] / SECONDS_IN_A_DAY);
}

@end
