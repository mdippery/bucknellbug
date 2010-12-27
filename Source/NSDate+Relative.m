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

#define DAY_COMPONENTS      (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit)
#define SECONDS_IN_A_DAY    (60 * 60 * 24)
#define sgn(x)              (x < 0.0 ? -1 : 1)

@interface NSCalendar (DefaultCalendar)
+ (id)defaultCalendar;
@end

@implementation NSCalendar (DefaultCalendar)

+ (id)defaultCalendar
{
    return [[[self alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
}

@end

@implementation NSDate (RelativeAdditions)

- (int)dayOfMonth
{
    return [[[NSCalendar defaultCalendar] components:NSDayCalendarUnit fromDate:self] day];
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
    NSDateComponents *this = [[NSCalendar defaultCalendar] components:DAY_COMPONENTS fromDate:self];
    NSDateComponents *now = [[NSCalendar defaultCalendar] components:DAY_COMPONENTS fromDate:[NSDate date]];
    return [this year] == [now year] && [this month] == [now month] && [this day] == [now day];
}

- (BOOL)isTomorrowOrLater
{
    NSDateComponents *this = [[NSCalendar defaultCalendar] components:DAY_COMPONENTS fromDate:self];
    NSDateComponents *now = [[NSCalendar defaultCalendar] components:DAY_COMPONENTS fromDate:[NSDate date]];
    if ([this year] == [now year]) {
        if ([this month] == [now month]) {
            return [this day] > [now day];
        } else {
            return [this month] > [now month];
        }
    } else {
        return [this year] > [now year];
    }
}

- (BOOL)isYesterdayOrEarlier
{
    NSDateComponents *this = [[NSCalendar defaultCalendar] components:DAY_COMPONENTS fromDate:self];
    NSDateComponents *now = [[NSCalendar defaultCalendar] components:DAY_COMPONENTS fromDate:[NSDate date]];
    if ([this year] == [now year]) {
        if ([this month] == [now month]) {
            return [this day] < [now day];
        } else {
            return [this month] < [now month];
        }
    } else {
        return [this year] < [now year];
    }
}

- (int)numberOfDaysSinceNow
{
    NSTimeInterval interval = [self timeIntervalSinceNow] / SECONDS_IN_A_DAY;
    if (sgn(interval) == -1) {
        // If the date is in the past, round down (6.5 days ago is 6
        // days ago, not 7)
        return (int) (floor(abs(interval)) * -1);
    } else {
        // If the date is in the future, round up (6.75 days from now is
        // 7 days from now, not 6).
        NSAssert1(sgn(interval) == 1, @"sgn(%.3f) must be either 1 or -1", interval);
        return (int) ceil(interval);
    }
}

@end
